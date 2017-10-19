// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:json_validator/dependencies.dart';

var map = {
  "orders": {
    "order0001": {
      "products": {
        "product001": {
          "amount": 3,
          "options": {
            "option001":"option001val001"
          }
        }
      }
    }
  },
  "products": {
    "product001": {
      "options": {
        "option001": {
          "option001val001":"blue",
          "option001val002":"red"
        }
      }
    }
  }
};

main() {
  var sourceTemplate = new SourceTemplate(["orders", "*", "products", "*", "options", "*"], true);
  var locationTemplate = new LocationTemplate(["products", "#1", "options", "#2", "VAL"], null);

  var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
  var locationList = new LocationList.fromSourceListAndTemplate(sourceList, locationTemplate);

  var verifiedLocationList = locationList.validateWithMap(map);
  print(verifiedLocationList);
}