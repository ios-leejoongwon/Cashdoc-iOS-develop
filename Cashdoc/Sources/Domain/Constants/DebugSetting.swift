//
//  DebugSetting.swift
//  Cashdoc
//
//  Created by DongHeeKang on 20/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

#if DEBUG
let DEBUG_SETTING = true
#elseif INHOUSE
let DEBUG_SETTING = true
#else
let DEBUG_SETTING = false
#endif
