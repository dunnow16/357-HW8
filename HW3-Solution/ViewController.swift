//
//  ViewController.swift
//  HW3-Solution
//
//  Created by Jonathan Engelsma on 9/7/18.
//  Copyright © 2018 Jonathan Engelsma. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SettingsViewControllerDelegate, HistoryTableViewControllerDelegate {
    
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var fromUnits: UILabel!
    @IBOutlet weak var toUnits: UILabel!
    @IBOutlet weak var calculatorHeader: UILabel!
    
    var currentMode : CalculatorMode = .Length
    var entries:[Conversion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toField.delegate = self
        fromField.delegate = self
        self.view.backgroundColor = BACKGROUND_COLOR
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    @IBAction func calculatePressed(_ sender: UIButton) {
        // determine source value of data for conversion and dest value for conversion
        var dest : UITextField?
        
        var val = ""
        if let fromVal = fromField.text {
            if fromVal != "" {
                val = fromVal
                dest = toField
            }
        }
        if let toVal = toField.text {
            if toVal != "" {
                val = toVal
                dest = fromField
            }
        }
        if dest != nil {
            switch(currentMode) {
            case .Length:
                var fUnits, tUnits : LengthUnit
                if dest == toField {
                    fUnits = LengthUnit(rawValue: fromUnits.text!)!
                    tUnits = LengthUnit(rawValue: toUnits.text!)!
                } else {
                    fUnits = LengthUnit(rawValue: toUnits.text!)!
                    tUnits = LengthUnit(rawValue: fromUnits.text!)!
                }
                if let fromVal = Double(val) {
                    let convKey =  LengthConversionKey(toUnits: tUnits, fromUnits: fUnits)
                    let toVal = fromVal * lengthConversionTable[convKey]!;
                    dest?.text = "\(toVal)"
                }
            case .Volume:
                var fUnits, tUnits : VolumeUnit
                if dest == toField {
                    fUnits = VolumeUnit(rawValue: fromUnits.text!)!
                    tUnits = VolumeUnit(rawValue: toUnits.text!)!
                } else {
                    fUnits = VolumeUnit(rawValue: toUnits.text!)!
                    tUnits = VolumeUnit(rawValue: fromUnits.text!)!
                }
                if let fromVal = Double(val) {
                    let convKey =  VolumeConversionKey(toUnits: tUnits, fromUnits: fUnits)
                    let toVal = fromVal * volumeConversionTable[convKey]!;
                    dest?.text = "\(toVal)"
                }
            }
        }
        
        let now = Date()
        print(now)
        entries.append(Conversion(fromVal: Double(fromField.text!)!, toVal: Double(toField.text!)!, mode: currentMode, fromUnits: fromUnits.text!, toUnits: toUnits.text!, timestamp: now))
        print(entries.count)
        
        self.view.endEditing(true)
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        self.fromField.text = ""
        self.toField.text = ""
        self.view.endEditing(true)
    }
    
    @IBAction func modePressed(_ sender: UIButton) {
        clearPressed(sender)
        switch (currentMode) {
        case .Length:
            currentMode = .Volume
            fromUnits.text = VolumeUnit.Gallons.rawValue
            toUnits.text = VolumeUnit.Liters.rawValue
//            fromField.placeholder =
//            toField.placeholder = "Enter volume in \(toUnits.text!)"
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter volume in \(fromUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter volume in \(toUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
        case .Volume:
            currentMode = .Length
            fromUnits.text = LengthUnit.Yards.rawValue
            toUnits.text = LengthUnit.Meters.rawValue
//            fromField.placeholder = "Enter length in \(fromUnits.text!)"
//            toField.placeholder = "Enter length in \(toUnits.text!)"
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter length in \(fromUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter length in \(toUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
        }

        calculatorHeader.text = "\(currentMode.rawValue) Conversion Calculator"
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            //clearPressed(sender as! UIButton)
            self.fromField.text = ""
            self.toField.text = ""
            if let target = segue.destination as? SettingsViewController {
                target.mode = currentMode
                target.fUnits = fromUnits.text
                target.tUnits = toUnits.text
                target.delegate = self
            }
        } else if segue.identifier == "historySegue" {
            if let target = segue.destination as? HistoryTableViewController {
                print("Going to history")
                target.entries = entries
                target.historyDelegate = self
            }
        }
    }
    
    func settingsChanged(fromUnits: LengthUnit, toUnits: LengthUnit)
    {
        self.fromUnits.text = fromUnits.rawValue
        self.toUnits.text = toUnits.rawValue
    }
    
    func settingsChanged(fromUnits: VolumeUnit, toUnits: VolumeUnit)
    {
        self.fromUnits.text = fromUnits.rawValue
        self.toUnits.text = toUnits.rawValue
    }
    
    func selectEntry(entry: Conversion) {
        self.fromUnits.text = entry.fromUnits
        self.toUnits.text = entry.toUnits
        self.toField.text = String(entry.toVal)
        self.fromField.text = String(entry.fromVal)
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == toField) {
            fromField.text = ""
        } else {
            toField.text = ""
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Date {
    struct Formatter {
        static let short: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
    }
    
    var short: String {
        return Formatter.short.string(from: self)
    }
}

extension UIButton {
    func toBarButtonItem() -> UIBarButtonItem? {
        return UIBarButtonItem(customView: self)
    }
}










