//
//  ContentType.swift
//
//
//  Created by Jeff Lebrun on 1/1/21.
//

/// The type of content owned by you or a `Group` you are in.
public enum ContentType {
	case featureServer(featureServer: FeatureServer, metadata: ContentItem)
	case other(metadata: ContentItem)
}
