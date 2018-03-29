//
//  config.hpp
//  categorical
//
//  Created by Nick Fagan on 3/27/18.
//

#pragma once

//  if the object is of size 0, allow the first call to
//  set category to fill the contents of the object
#define CAT_ALLOW_SET_FROM_SIZE0

//  during assignment, copy the `m_labels` variable, such that
//  errors during assignment don't mutate the object.
#define CAT_COPY_ASSIGN_FROM

//  call prune after assignment operation (set_category, assign),
//  ensuring that each label in `m_label_ids` corresponds to at least
//  one row in the array. Otherwise, `m_label_ids` may contain "dangling"
//  labels.
//#define CAT_PRUNE_AFTER_ASSIGN

#define CAT_USE_PROGENITOR_IDS
