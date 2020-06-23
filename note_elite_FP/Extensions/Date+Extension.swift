//
//  Date+Extension.swift
//  note_elite_FP
//
//  Created by Anmol singh on 2020-06-22.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import Foundation

extension Date {
func getFormattedDate(format: String) -> String {
     let dateformat = DateFormatter()
     dateformat.dateFormat = format
     return dateformat.string(from: self)
 }
}
