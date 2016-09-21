/**
 * Copyright Michal Kalinowski 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
import Foundation

@testable import KituraRequest

class RequestTests: XCTestCase {

  var testRequest = KituraRequest.request(.POST,
                                          "https://google.com",
                                          parameters: ["asd":"asd"],
                                          headers: ["User-Agent":"Kitura-Server"]
  )

  func testRequestAssignsClientRequestURL() {
    XCTAssertEqual(testRequest.request?.url, URL(string: "https://google.com?asd=asd"))
  }

  func testRequestAssignClientRequestMethod() {
    XCTAssertEqual(testRequest.request?.httpMethod, "POST")
  }

  func testRequestAssignsClientRequestHeaders() {
    if let headers = testRequest.request?.allHTTPHeaderFields {
      XCTAssertEqual(headers["User-Agent"], "Kitura-Server")
    } else {
      XCTFail()
    }
  }

    func testMultipartRequest() {
        let expectation1 = expectation(description: "multipart test")
        KituraRequest.request(.GET,
            "http://httpbin.org/image/png").response { _, _, data, error in
                guard let data = data else {
                    XCTFail("Data should exist")
                    expectation1.fulfill()
                    return;
                }

                KituraRequest.request(.POST,
                    "http://httpbin.org/post",
                    parameters: [
                        "key" : "value"
                    ], encoding: MultipartEncoding([
                        BodyPart(key: "file", data: data, mimeType: .image(.png), fileName: "image.jpg")
                    ])).response { _, _, data, error in

                        guard let string = dataToString(data) else {
                            XCTFail("Can't parse response")
                            expectation1.fulfill()
                            return
                        }

                        XCTAssertTrue(string.contains("\"file\": \"data:image/png;base64,"), "file should exits in request")
                        XCTAssertTrue(string.contains("\"key\": \"value\""), "key value should exits in request")

                        expectation1.fulfill()
                }
            }
        waitForExpectations(timeout: 5)
    }
}

extension RequestTests {
  static var allTests : [(String, (RequestTests) -> () throws -> Void)] {
    return [
        ("testRequestAssignsClientRequestURL", testRequestAssignsClientRequestURL),
        ("testRequestAssignClientRequestMethod", testRequestAssignClientRequestMethod),
        ("testRequestAssignsClientRequestHeaders", testRequestAssignsClientRequestHeaders),
        ("testMultipartRequest", testMultipartRequest)
    ]
  }
}
