// Copyright (c) 2022 Jeff Lebrun
//
//  Licensed under the MIT License.
//
//  The full text of the license can be found in the file named LICENSE.

/// The type of content owned by you or a `Group` you are in.
public enum ContentType {
	case featureServer(featureServer: FeatureServer, metadata: ContentItem)
	case other(metadata: ContentItem)
}
