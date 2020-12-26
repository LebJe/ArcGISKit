import json
import traceback
import logging

try:
    from ._ner_spacy import _SpacyEntityRecognizer
    from .._utils._ner_utils import spaCyNERDatabunch
    HAS_SPACY = True
except Exception as e:
    spacy_exception = "\n".join(traceback.format_exception(type(e), e, e.__traceback__))
    HAS_SPACY = False

try:
    from ._ner_transformer import _TransformerEntityRecognizer
    from .._utils.text_data import TextDataObject
    from .._utils.common import _get_emd_path
    HAS_TRANSFORMERS = True
except Exception as e:
    transformer_exception = "\n".join(traceback.format_exception(type(e), e, e.__traceback__))
    HAS_TRANSFORMERS = False
    class _TransformerEntityRecognizer:
        supported_backbones = []


def _raise_spacy_import_error():
    error_message = (f"{spacy_exception}\n\n\n"
                     "This module requires spacy version 2.1.8 or above and fastprogress." 
                     "Install it using 'pip install spacy==2.1.8 fastprogress pandas'")
    raise Exception(error_message)


def _raise_transformers_import_error():
    error_message = (f"{transformer_exception}\n\n\n"
                     "This module requires transformers version 3.3.0, " 
                     "install it using 'pip install transformers==3.3.0'")
    raise Exception(error_message)


class EntityRecognizer:
    """
    Creates an entity recognition model to extract text entities from unstructured text documents.

    =====================   ===========================================
    **Argument**            **Description**
    ---------------------   -------------------------------------------
    data                    Requires data object returned from
                            ``prepare_data`` function.
    ---------------------   -------------------------------------------
    lang                    Optional string. Language-specific code,
                            named according to the language’s `ISO code <https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes>`_
                            The default value is 'en' for English.
    ---------------------   -------------------------------------------
    backbone                Optional string. Specify `spacy` or the  HuggingFace
                            transformer model name to be used to train the
                            entity recognizer model. Default set to `spacy`.

                            Entity recognition via `spaCy` is based on
                            <https://spacy.io/api/entityrecognizer>

                            To learn more about the available transformer models or
                            choose models that are suitable for your dataset,
                            kindly visit:- https://huggingface.co/transformers/pretrained_models.html
    =====================   ===========================================

    **kwargs**

    =====================   ===========================================
    **Argument**            **Description**
    ---------------------   -------------------------------------------
    verbose                 Optional string. Default set to `error`. The
                            log level you want to set. It means the amount
                            of information you want to display while training
                            or calling the various methods of this class.
                            Allowed values are - `debug`, `info`, `warning`,
                            `error` and `critical`. Applicable only for models
                            with HuggingFace transformer backbones.
    ---------------------   -------------------------------------------
    seq_len                 Optional Integer. Default set to 512. Maximum
                            sequence length (at sub-word level after tokenization)
                            of the training data to be considered for training
                            the model. Applicable only for models with
                            HuggingFace transformer backbones.
    ---------------------   -------------------------------------------
    mixed_precision         Optional Bool. Default set to False. If set
                            True, then mixed precision training is used
                            to train the model. Applicable only for models
                            with HuggingFace transformer backbones.
    ---------------------   -------------------------------------------
    pretrained_path         Optional String. Path where pre-trained model
                            is saved. Accepts a Deep Learning Package
                            (DLPK) or Esri Model Definition(EMD) file.
    =====================   ===========================================

    :returns: ``EntityRecognizer`` Object
    """

    supported_backbones = ["spacy"] + _TransformerEntityRecognizer.supported_backbones

    def __init__(self, data, lang="en", backbone="spacy", **kwargs):
        self.data = data
        self.lang = lang
        self.backbone = backbone
        self.entities = None
        create_empty = kwargs.get("create_empty", False)

        if create_empty:
            pass
        else:
            if backbone == "spacy":
                if not HAS_SPACY: _raise_spacy_import_error()
                if data.backbone != "spacy":
                    logging.info("Preparing data for spacy backbone!")
                    data.prepare_data_for_spacy()
                data_obj = data.get_data_object()
                self._model = _SpacyEntityRecognizer(data_obj, lang=lang, **kwargs)
            else:
                if not HAS_TRANSFORMERS: _raise_transformers_import_error()
                if data.backbone == "spacy":
                    logging.info("Preparing data for transformer backbone!")
                    data.prepare_data_for_transformer()
                data_obj = data.get_data_object()
                self._model = _TransformerEntityRecognizer(data_obj, backbone, **kwargs)

        if create_empty is False:
            self.train_ds = self._model.train_ds
            self.valid_ds = self._model.val_ds

        from IPython.display import clear_output
        clear_output()

    @classmethod
    def available_backbone_models(cls, architecture):
        """
        Get available models for the given entity recognition backbone

        =====================   ===========================================
        **Argument**            **Description**
        ---------------------   -------------------------------------------
        architecture            Required string. name of the architecture
                                one wishes to use. To learn more about
                                the available models or choose models that are
                                suitable for your dataset, kindly visit:-
                                https://huggingface.co/transformers/pretrained_models.html
        =====================   ===========================================

        :returns: a tuple containing the available models for the given entity recognition backbone
        """

        if architecture == "spacy":
            return ("spacy", )
        else:
            return _TransformerEntityRecognizer.available_backbone_models(architecture)

    def lr_find(self, allow_plot=True):
        """
        Runs the Learning Rate Finder, and displays the graph of it's output.
        Helps in choosing the optimum learning rate for training the model.
        """
        return self._model.lr_find(allow_plot=allow_plot)

    def unfreeze(self):
        """
        Unfreezes the earlier layers of the model for fine-tuning.
        """
        self._model.unfreeze()

    def fit(self, epochs=20, lr=None, one_cycle=True, early_stopping=False, checkpoint=True, **kwargs):
        """
        Train the model for the specified number of epochs and using the
        specified learning rates

        =====================   ===========================================
        **Argument**            **Description**
        ---------------------   -------------------------------------------
        epochs                  Optional integer. Number of cycles of training
                                on the data. Increase it if underfitting.

                                The default value is 20.
        ---------------------   -------------------------------------------
        lr                      Optional float or slice of floats. Learning rate
                                to be used for training the model. If ``lr=None``,
                                an optimal learning rate is automatically deduced
                                for training the model.
                                **Note - Passing slice of floats as `lr` value
                                is not supported for models with `spaCy` backbone.
        ---------------------   -------------------------------------------
        one_cycle               Optional boolean. Parameter to select 1cycle
                                learning rate schedule. If set to `False` no
                                learning rate schedule is used.
                                **Note - Not applicable for models with spaCy backbone
        ---------------------   -------------------------------------------
        early_stopping          Optional boolean. Parameter to add early stopping.
                                If set to 'True' training will stop if validation
                                loss stops improving for 5 epochs.
                                **Note - Not applicable for models with spaCy backbone
        ---------------------   -------------------------------------------
        checkpoint              Optional boolean. Parameter to save the best model
                                during training. If set to `True` the best model
                                based on validation loss will be saved during
                                training.
                                **Note - Not applicable for models with spaCy backbone
        =====================   ===========================================
        """

        self._model.fit(epochs=epochs, lr=lr, one_cycle=one_cycle, early_stopping=early_stopping,
                        checkpoint=checkpoint, **kwargs)
        self.entities = self._model.entities

    def save(self, name_or_path, **kwargs):
        """
        Saves the model weights, creates an Esri Model Definition and Deep
        Learning Package zip for deployment to Image Server or ArcGIS Pro.

        =====================   ===========================================
        **Argument**            **Description**
        ---------------------   -------------------------------------------
        name_or_path            Required string. Name of the model to save. It
                                stores it at the pre-defined location. If path
                                is passed then it stores at the specified path
                                with model name as directory name and creates
                                all the intermediate directories.
        ---------------------   -------------------------------------------
        publish                 Optional boolean. Publishes the DLPK as an item.
                                Default is set to False.
        ---------------------   -------------------------------------------
        gis                     Optional GIS Object. Used for publishing the item.
                                If not specified then active gis user is taken.
        ---------------------   -------------------------------------------
        compute_metrics         Optional boolean. Used for computing model
                                metrics. Default is set to True.
        ---------------------   -------------------------------------------
        save_optimizer          Optional boolean. Used for saving the model-optimizer
                                state along with the model. Default is set to False
                                Not applicable for models with `spaCy` backbone.
        ---------------------   -------------------------------------------
        kwargs                  Optional Parameters:
                                Boolean `overwrite` if True, it will overwrite
                                the item on ArcGIS Online/Enterprise, default False.
                                Boolean `zip_files` if True, it will create the Deep
                                Learning Package (DLPK) file while saving the model.
        =====================   ===========================================
        """

        return self._model.save(name_or_path=name_or_path, **kwargs)

    def load(self, name_or_path):
        """
        Loads a saved EntityRecognizer model from disk.

        =====================   ===========================================
        **Argument**            **Description**
        ---------------------   -------------------------------------------
        name_or_path            Required string. Path to Deep Learning Package
                                (DLPK) or Esri Model Definition(EMD) file.
        =====================   ===========================================
        """

        self._model.load(name_or_path=name_or_path)
        self.entities = self._model.entities

    @classmethod
    def from_model(cls, emd_path, data=None):
        """
        Creates an EntityRecognizer model object from a Deep Learning
        Package(DLPK) or Esri Model Definition (EMD) file.

        =====================   ===========================================
        **Argument**            **Description**
        ---------------------   -------------------------------------------
        emd_path                Required string. Path to Deep Learning Package
                                (DLPK) or Esri Model Definition(EMD) file.
        ---------------------   -------------------------------------------
        data                    Required DatabunchNER object or None. Returned data
                                object from `prepare_data` function or None for
                                inferencing.

        =====================   ===========================================

        :returns: `EntityRecognizer` Object
        """

        data_obj = None
        emd_path = _get_emd_path(emd_path)
        with open(emd_path) as f:
            emd_json = json.load(f)
        backbone = emd_json.get("ModelType", "spacy").lower()
        if backbone == "spacy":
            if data and data.backbone != "spacy":
                logging.info("Preparing data for spacy backbone!")
                data.prepare_data_for_spacy()
            if data: data_obj = data.get_data_object()
            model = _SpacyEntityRecognizer.from_model(emd_path=emd_path, data=data_obj)
        else:
            if data and data.backbone == "spacy":
                logging.info("Preparing data for transformer backbone!")
                data.prepare_data_for_transformer()
            if data: data_obj = data.get_data_object()
            model = _TransformerEntityRecognizer.from_model(emd_path=emd_path, data=data_obj)

        clas_object = cls(data=None, backbone=backbone, create_empty=True)

        clas_object._model = model
        clas_object.entities = clas_object._model.entities
        clas_object.train_ds = clas_object._model.train_ds
        clas_object.valid_ds = clas_object._model.val_ds

        return clas_object

    def extract_entities(self, text_list, drop=True, batch_size=4):
        """
        Extracts the entities from [documents in the mentioned path or text_list].

        Field defined as 'address_tag' in `prepare_data()` function's class mapping
        attribute will be treated as a location. In cases where trained model extracts
        multiple locations from a single document, that document will be replicated
        for each location in the resulting dataframe.

        =====================   ===========================================
        **Argument**            **Description**
        ---------------------   -------------------------------------------
        text_list               Required string(path) or list(documents).
                                List of documents for entity extraction OR
                                path to the documents.
        ---------------------   -------------------------------------------
        drop                    Optional bool. If documents without address
                                needs to be dropped from the results.
                                Default is set to True.
        ---------------------   -------------------------------------------
        batch_size              Optional integer. Number of items to process
                                at once. (Reduce it if getting CUDA Out of Memory
                                Errors). Default is set to 4.
                                Not applicable for models with `spaCy` backbone.
        =====================   ===========================================

        :returns: Pandas DataFrame
        """

        return self._model.extract_entities(text_list, drop=drop, batch_size=batch_size)

    def show_results(self, ds_type='valid'):
        """
        Runs entity extraction on a random batch from the mentioned ds_type.

        =====================   ===========================================
        **Argument**            **Description**
        ---------------------   -------------------------------------------
        ds_type                 Optional string, defaults to valid.
        =====================   ===========================================

        :returns: Pandas DataFrame
        """

        return self._model.show_results(ds_type=ds_type)

    def precision_score(self):
        """
        Calculate precision score of the trained model
        """
        return self._model.precision_score()

    def recall_score(self):
        """
        Calculate recall score of the trained model
        """
        return self._model.recall_score()

    def f1_score(self):
        """
        Calculate F1 score of the trained model
        """
        return self._model.f1_score()

    def metrics_per_label(self):
        """
        Calculate precision, recall & F1 scores per labels/entities
        for which the model was trained on
        """
        return self._model.metrics_per_label()

    def plot_losses(self, show=True):
        """
        Plot training and validation losses.

        =====================   ===========================================
        **Argument**            **Description**
        ---------------------   -------------------------------------------
        show                    Optional bool. Defaults to True
                                If set to False, figure will not be plotted
                                but will be returned, when set to True function
                                will plot the figure and return nothing.
        =====================   ===========================================

        :returns: matplotlib.figure.Figure
        """

        return self._model.plot_losses(show=show)
