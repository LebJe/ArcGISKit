//
//  Privileges.swift
//
//
//  Created by Jeff Lebrun on 12/23/20.
//

public enum Privilege: String, Codable, CaseIterable {
	// MARK: - ArcGIS Marketplace subscriptions.

	case marketplaceAdminManage = "marketplace:admin:manage"
	case marketplaceAdminPurchase = "marketplace:admin:purchase"
	case marketplaceAdminStartTrial = "marketplace:admin:startTrial"

	case opendataUserDesignateGroup = "opendata:user:designateGroup"
	case opendataUserOpenDataAdmin = "opendata:user:openDataAdmin"

	// MARK: - Administrative privileges.

	case portalAdminAssignToGroups = "portal:admin:assignToGroups"
	case portalAdminCategorizeItems = "portal:admin:categorizeItems"
	case portalAdminChangeUserRoles = "portal:admin:changeUserRoles"
	case portalAdminCreateCollaborationCapableGroup = "portal:admin:createCollaborationCapableGroup"
	case portalAdminCreateUpdateCapableGroup = "portal:admin:createUpdateCapableGroup"
	case portalAdminDeleteGroups = "portal:admin:deleteGroups"
	case portalAdminDeleteItems = "portal:admin:deleteItems"
	/// Grants the ability to delete member accounts within organization
	case portalAdminDeleteUsers = "portal:admin:deleteUsers"

	case portalAdminDisableUsers = "portal:admin:disableUsers"

	/// ArcGIS Online only. Grants the ability to invite members to organization.
	case portalAdminInviteUsers = "portal:admin:inviteUsers"

	case portalAdminManageCollaborations = "portal:admin:manageCollaborations"
	case portalAdminManageCredits = "portal:admin:manageCredits"
	case portalAdminManageEnterpriseGroups = "portal:admin:manageEnterpriseGroups"
	case portalAdminManageLicenses = "portal:admin:manageLicenses"
	case portalAdminManageRoles = "portal:admin:manageRoles"
	case portalAdminManageSecurity = "portal:admin:manageSecurity"
	case portalAdminManageServers = "portal:admin:manageServers"
	case portalAdminManageUtilityServices = "portal:admin:manageUtilityServices"
	case portalAdminManageWebsite = "portal:admin:manageWebsite"
	case portalAdminReassignGroups = "portal:admin:reassignGroups"
	case portalAdminReassignItems = "portal:admin:reassignItems"
	case portalAdminReassignUsers = "portal:admin:reassignUsers"
	case portalAdminShareToGroup = "portal:admin:shareToGroup"
	case portalAdminShareToOrg = "portal:admin:shareToOrg"
	case portalAdminShareToPublic = "portal:admin:shareToPublic"
	case portalAdminUpdateGroups = "portal:admin:updateGroups"
	case portalAdminUpdateItemCategorySchema = "portal:admin:updateItemCategorySchema"
	case portalAdminUpdateItems = "portal:admin:updateItems"

	/// Grants the ability to update member account information within organization
	case portalAdminUpdateUsers = "portal:admin:updateUsers"
	case portalAdminViewGroups = "portal:admin:viewGroups"
	case portalAdminViewItems = "portal:admin:viewItems"

	/// Grants the ability to view full member account information within organization
	case portalAdminViewUsers = "portal:admin:viewUsers"

	// MARK: - Publisher privileges.

	case portalPublisherBulkPublishFromDataStores = "portal:publisher:bulkPublishFromDataStores"
	case portalPublisherPublishBigDataAnalytics = "portal:publisher:publishBigDataAnalytics"
	case portalPublisherPublishDynamicImagery = "portal:publisher:publishDynamicImagery"
	case portalPublisherPublishFeatures = "portal:publisher:publishFeatures"
	case portalPublisherPublishFeeds = "portal:publisher:publishFeeds"
	case portalPublisherPublishRealTimeAnalytics = "portal:publisher:publishRealTimeAnalytics"
	case portalPublisherPublishScenes = "portal:publisher:publishScenes"
	case portalPublisherPublishServerGPServices = "portal:publisher:publishServerGPServices"
	case portalPublisherPublishServerServices = "portal:publisher:publishServerServices"
	case portalPublisherPublishTiledImagery = "portal:publisher:publishTiledImagery"
	case portalPublisherPublishTiles = "portal:publisher:publishTiles"
	case portalPublisherRegisterDataStores = "portal:publisher:registerDataStores"
	case premiumPublisherCreateAdvancedNotebooks = "premium:publisher:createAdvancedNotebooks"
	case premiumPublisherCreateNotebooks = "premium:publisher:createNotebooks"

	// MARK: - User privileges.

	case portalUserCategorizeItems = "portal:user:categorizeItems"

	case portalUserCreateItem = "portal:user:createItem"

	case portalUserShareGroupToOrg = "portal:user:shareGroupToOrg"
	case portalUserShareGroupToPublic = "portal:user:shareGroupToPublic"
	case portalUserShareToGroup = "portal:user:shareToGroup"
	case portalUserShareToOrg = "portal:user:shareToOrg"
	case portalUserShareToPublic = "portal:user:shareToPublic"
	case portalUserViewOrgItems = "portal:user:viewOrgItems"

	// MARK: - User privileges: Members.

	case portalUserViewOrgUsers = "portal:user:viewOrgUsers"

	// MARK: - User privileges: Groups.

	case portalUserCreateGroup = "portal:user:createGroup"
	case portalUserJoinGroup = "portal:user:joinGroup"
	case portalUserJoinNonOrgGroup = "portal:user:joinNonOrgGroup"
	case portalUserViewOrgGroups = "portal:user:viewOrgGroups"

	// MARK: - User privileges: Content.

	case portalUserViewTracks = "portal:user:viewTracks"

	case featuresUserEdit = "features:user:edit"
	case featuresUserFullEdit = "features:user:fullEdit"
	case featuresUserManageVersions = "features:user:manageVersions"

	case premiumPublisherGeoanalytics = "premium:publisher:geoanalytics"
	case premiumPublisherRasteranalysis = "premium:publisher:rasteranalysis"
	case premiumPublisherScheduleNotebooks = "premium:publisher:scheduleNotebooks"

	case premiumUserDemographics = "premium:user:demographics"
	case premiumUserElevation = "premium:user:elevation"
	case premiumUserFeaturereport = "premium:user:featurereport"
	case premiumUserGeocode = "premium:user:geocode"
	case premiumUserGeocodeStored = "premium:user:geocode:stored"
	case premiumUserGeocodeTemporary = "premium:user:geocode:temporary"
	case premiumUserGeoenrichment = "premium:user:geoenrichment"
	case premiumUserNetworkanalysis = "premium:user:networkanalysis"
	case premiumUserNetworkanalysisClosestfacility = "premium:user:networkanalysis:closestfacility"
	case premiumUserNetworkanalysisLocationallocation = "premium:user:networkanalysis:locationallocation"
	case premiumUserNetworkanalysisOptimizedrouting = "premium:user:networkanalysis:optimizedrouting"
	case premiumUserNetworkanalysisOrigindestinationcostmatrix = "premium:user:networkanalysis:origindestinationcostmatrix"
	case premiumUserNetworkanalysisRouting = "premium:user:networkanalysis:routing"
	case premiumUserNetworkanalysisServicearea = "premium:user:networkanalysis:servicearea"
	case premiumUserNetworkanalysisVehiclerouting = "premium:user:networkanalysis:vehiclerouting"
	case premiumUserSpatialanalysis = "premium:user:spatialanalysis"
}
