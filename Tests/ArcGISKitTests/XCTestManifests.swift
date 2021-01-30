import XCTest

#if !canImport(ObjectiveC)
	public func allTests() -> [XCTestCaseEntry] {
		[
			testCase(ArcGISKitTests.allTests),
		]
	}
#endif
