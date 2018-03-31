//
//  Device.swift
//  Table
//
//  Created by Bradley Hilton on 3/20/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

import DeviceKit

let deviceBenchmark = Device().benchmark

extension Device {
    
    /// https://browser.primatelabs.com/ios-benchmarks
    fileprivate var benchmark: Int {
        switch self {
        case .iPodTouch5: return 280
        case .iPodTouch6: return 1315
        case .iPhone4s: return 282
        case .iPhone5: return 727
        case .iPhone5c: return 716
        case .iPhone5s: return 1204
        case .iPhone6: return 1465
        case .iPhone6Plus: return 1475
        case .iPhone6s: return 2371
        case .iPhone6sPlus: return 2397
        case .iPhone7: return 3298
        case .iPhone7Plus: return 3308
        case .iPhoneSE: return 2406
        case .iPhone8: return 4217
        case .iPhone8Plus: return 4216
        case .iPhoneX: return 4205
        case .iPad2: return 330
        case .iPad3: return 326
        case .iPad4: return 803
        case .iPad5: return 2523
        case .iPadAir: return 1308
        case .iPadAir2: return 1783
        case .iPadMini: return 326
        case .iPadMini2: return 1233
        case .iPadMini3: return 1231
        case .iPadMini4: return 1632
        case .iPadPro9Inch: return 2935
        case .iPadPro12Inch: return 3012
        case .iPadPro12Inch2: return 3903
        case .iPadPro10Inch: return 3908
        case .simulator(let device): return device.benchmark
        default: return Device.iPhoneSE.benchmark
        }
    }
    
}

