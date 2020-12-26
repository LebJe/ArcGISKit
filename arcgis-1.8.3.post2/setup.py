"""A setuptools based setup module.
See:
https://packaging.python.org/en/latest/distributing.html
https://github.com/pypa/sampleproject
"""

# Always prefer setuptools over distutils
from setuptools import setup
from setuptools import find_packages
from setuptools.command.develop import develop as _develop
from setuptools.command.install import install as _install
from setuptools.command.egg_info import egg_info as _egg_info

# To use a consistent encoding
from codecs import open
from os import path
import sys
from glob import glob
from subprocess import check_output, CalledProcessError, STDOUT
import atexit
import logging
import site
log = logging.getLogger()
here = path.abspath(path.dirname(__file__))

def _get_rel_site_packages_dir():
    for sitepackages in site.getsitepackages():
        try:
            res = "lib" + sitepackages.split("lib")[1] + "/arcgis/gis/_impl"
            if res:
                return res
        except Exception:
            pass

# Conda uses this setup file, but we want to suppress some functionality
if "--conda-install-mode" in sys.argv:
    sys.argv.remove("--conda-install-mode")
    conda_install_mode = True
else:
    conda_install_mode = False

if conda_install_mode:
    # conda handles its own dependencies, so don't specify any pip-dependencies
    dependencies = []
else:
    dependencies = [
        'six',
        'ipywidgets >=7',
        'widgetsnbextension >=3',
        'pandas >=1',
        'numpy >=1.16.2',
        'matplotlib',
        'keyring >=19',
        'lerc',
        'ujson >=3',
        'jupyterlab',
        'python-certifi-win32',
        'pywin32 >=223;platform_system=="Windows"',
        'pyshp >=2',
        'requests',
        'requests-oauthlib',
        'requests_toolbelt',
        'requests_ntlm',
        'requests-negotiate-sspi;platform_system=="Windows"',
        'requests-kerberos;platform_system=="Windows"',
        'winkerberos;platform_system=="Windows"' ]

def _post_install():
    """This function will run after 'pip install' finishes. It has 2 parts:
    1) activate the notebook map widget, equivalent of running these cmds:
        - jupyter nbextension install --py --sys-prefix arcgis
        - jupyter nbextension enable --py --sys-prefix arcgis
        - jupyter nbextension enable --py --sys-prefix widgetsnbextension
    2) If the O.S. is Mac OSX, run the OpenSSL workaround as described in
       this issue: https://bugs.python.org/issue28150, equivalent of running
       '/Applications/Python X.X/Install Certificates.command' cmd
    """
    if conda_install_mode:
        # Don't run any post installation methods for conda installs
        return

    # 1) activate the notebook map widget
    try:
        import notebook.nbextensions as nbext
        import arcgis
        activate_map_widget = True
    except Exception:
        log.exception("arcgis/notebook packages don't appear to be installed: "\
                      "map widget not activated, may not work. The rest of "\
                      "install is unaffected by this. Exception caught: ")
        activate_map_widget = False

    if activate_map_widget:
        log.warn("Attempting to activate map widget...")
        try:
            log.warn(nbext.install_nbextension_python("arcgis",
                                              sys_prefix = True, logger = log))
            log.warn(nbext.enable_nbextension_python("arcgis",
                                              sys_prefix = True, logger = log))
            log.warn(nbext.enable_nbextension_python("widgetsnbextension",
                                              sys_prefix = True, logger = log))
        except Exception:
            log.exception("Activating map widget failed: Continuing install..")

    # 2) If the OS is Mac OSX, run the OpenSSL workaround
    platform_is_osx = sys.platform == "darwin"
    if not platform_is_osx:
        return
    for potential_cert_script in glob("/Applications/Python*/*"):
        if "Install Certificates.command" in potential_cert_script:
            try:
                cmd_output = check_output(potential_cert_script,
                                          stderr=STDOUT)
                log.warn("OpenSSL workaround for OSX completed successfully. "\
                         "See https://bugs.python.org/issue28150 for info. "\
                         "Output: {}".format(cmd_output.decode("utf-8")))
            except Exception:
                log.exception("OpenSSL workaround for OSX did not complete "\
                         "successfully. This may or may not allow secure SSL "
                         "to work. See https://bugs.python.org/issue28150. ")

# Each of these classes represent the different modes that pip install
# can go into, and what logic can be run after pip install finishes
class develop(_develop):
    """Post-installation logic to run for development mode"""
    def run(self):
        self.execute(_post_install, (), msg="Running post-install...")
        super().run()

class install(_install):
    """Post-installation logic to run for installation mode"""
    def run(self):
        self.execute(_post_install, (), msg="Running post-install...")
        super().run()

class egg_info(_egg_info):
    """Post-installation logic to run for 'egg_info' mode"""
    def run(self):
        self.execute(_post_install, (), msg="Running post-install...")
        super().run()

#Read the description.md file
description_md_file = open("pypi_long_description.md", "r")
long_description = description_md_file.read()
description_md_file.close()

#Assemble the `data_files` list of all non-python files
data_files = [('share/jupyter/nbextensions/arcgis', [
                   'arcgis/widgets/js/dist/extension.js',
                   'arcgis/widgets/js/dist/arcgis-map-ipywidget.js',
                   'arcgis/widgets/js/dist/arcgis-map-ipywidget.js.map',
                   'arcgis/apps/workforce/_store/resources/default-project-thumbnail.png'
                   ]),
             ]
data_files += [] if ("win" in sys.platform or "darwin" in sys.platform) else \
              [(_get_rel_site_packages_dir() + "arcgis/gis/_impl", [
                 "arcgis/gis/_impl/_decrypt_nbauth.cpython-36m-x86_64-linux-gnu.so",
                 "arcgis/gis/_impl/_decrypt_nbauth.cpython-37m-x86_64-linux-gnu.so"])
              ]

kwargs = {
    "name":'arcgis',

    # Versions should comply with PEP440.  For a discussion on single-sourcing
    # the version across setup.py and the project code, see
    # https://packaging.python.org/en/latest/single_source_version.html
    "version":'1.8.3.post2',

    "description":'ArcGIS API for Python',
    "long_description":long_description,
    "long_description_content_type":"text/markdown",

    # The project's main homepage.
    "url":'https://developers.arcgis.com/python/',

    # Author details
    "author":'Esri',
    "author_email":'python@esri.com',

    # Choose your license
    "license":'Esri Master License Agreement (MLA) - http://www.esri.com/LEGAL/pdfs/mla_e204_e300/english.pdf',

    # See https://pypi.python.org/pypi?%3Aaction=list_classifiers
    "classifiers":[
        # How mature is this project? Common values are
        'Development Status :: 5 - Production/Stable',

        # Topics
        'Topic :: Scientific/Engineering :: GIS',
        'Topic :: Internet :: WWW/HTTP :: Site Management',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Scientific/Engineering :: Visualization',
        'Topic :: Software Development :: Libraries :: Python Modules',

        # Indicate who your project is intended for
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',

        # Frameworks
        'Framework :: IPython',
        'Framework :: Jupyter',

        # OS
        'Operating System :: OS Independent',

        # Pick your license as you wish (should match "license" above)
        'License :: Other/Proprietary License',

        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.
        'Programming Language :: Python :: 3 :: Only',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
    ],

    # What does your project relate to?
    "keywords":'gis arcgis geographic spatial spatial-data '\
             'spatial-data-analysis spatial-analysis data-science maps '\
             'mapping web-mapping python native-development',

    # You can just specify the packages manually here if your project is
    # simple. Or you can use find_packages().
    # packages=find_packages(exclude=['contrib', 'docs', 'tests']),

    # Alternatively, if you want to distribute just a my_module.py, uncomment
    # this:
    "packages":find_packages(),
    "include_package_data":True,
    'data_files': data_files,
    # List run-time dependencies here.  These will be installed by pip when
    # your project is installed. For an analysis of "install_requires" vs pip's
    # requirements files see:
    # https://packaging.python.org/en/latest/requirements.html
    # `setup_dependencies` are all dependencies that need to be in the env
    # BEFORE setup() is called. `install_dependencies` are dependencies
    # that can be put in the env AFTER setup() is finished. See bottom of this
    # file, any unhandled exception will clear `setup_requires` and try again
    # It was thought `setup_requires` needed `notebook` and other deps to
    # activate the map widget, but it caused build errors on windows with
    # required VS C++ distrib (even for --no-deps). See geosaurus/issues/964
    "install_requires": dependencies,
    "setup_requires": dependencies,

    # These classes will execute code after 'pip install' finishes
    # In this case, it will activate the 'arcgis' ipywidget
    # See the top of this setup.py file
    "cmdclass":{
            'develop': develop,
            'install': install,
            'egg_info': egg_info},

    # List additional groups of dependencies here (e.g. development
    # dependencies). You can install these using the following syntax,
    # for example:
    # $ pip install -e .[dev,test]
    "extras_require":{
        'gp': ['dill'],

    },

    # extras_require={
    #     'dev': ['check-manifest'],
    #     'test': ['coverage'],
    # },

    # If there are data files included in your packages that need to be
    # installed, specify them here.  If using Python 2.6 or less, then these
    # have to be included in MANIFEST.in as well.
    # package_data={
    #     'sample': ['package_data.dat'],
    # },
    'package_data':{
        'arcgis':['raster/*.dll', 'raster/*.so', 'learn/*.dll', 'learn/*.so'],
    },

    # Although 'package_data' is the preferred approach, in some case you may
    # need to place data files outside of your packages. See:
    # http://docs.python.org/3.4/distutils/setupscript.html#installing-additional-files # noqa
    # In this case, 'data_file' will be installed into '<sys.prefix>/my_data'
    # data_files=[('my_data', ['data/data_file'])],

    # To provide executable scripts, use entry points in preference to the
    # "scripts" keyword. Entry points provide cross-platform support and allow
    # pip to create the appropriate form of executable for the target platform.
    # entry_points={
    #     'console_scripts': [
    #         'sample=sample:main',
    #     ],
    # },
}

try:
    setup(**kwargs)
except Exception:
    log.exception("Exception encountered when attempting to install: Setting "\
        "`setup_requires` arg to `[]` and trying again. Exception:\n-----\n")
    kwargs["setup_requires"] = []
    setup(**kwargs)
