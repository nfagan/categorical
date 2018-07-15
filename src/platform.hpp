//
//  platform.hpp
//  categorical
//
//  Created by Nick Fagan on 7/15/18.
//

#pragma once

#define CAT_HAS_TRIVIALLY_COPYABLE

#ifdef __GNUC__
    #if __GNUC__ < 5
    #undef CAT_HAS_TRIVIALLY_COPYABLE
    #endif
#endif
