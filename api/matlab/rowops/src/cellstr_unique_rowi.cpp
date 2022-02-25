#include "mex.h"
#include <vector>
#include <string>
#include <unordered_map>

namespace {
  
constexpr const char* err_id() {
  return "cellstr_unique_rows:main";
}
  
} //  anon

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{   
  if (nrhs != 1) {
    mexErrMsgIdAndTxt(err_id(), "Expected 1 input.");
  }
  if (nlhs != 2) {
    mexErrMsgIdAndTxt(err_id(), "Expected 2 outputs.");
  }
  if (mxGetClassID(prhs[0]) != mxCELL_CLASS || 
      mxGetNumberOfDimensions(prhs[0]) != 2) {
    mexErrMsgIdAndTxt(err_id(), "Expected cell matrix input.");
  }
  
  const auto* a = prhs[0];
  const auto* dims = mxGetDimensions(a);
  const int64_t num_elements = dims[0] * dims[1];
  std::vector<uint32_t> ids(num_elements);
  
  std::string s;
  std::unordered_map<std::string, uint32_t> strings;
  {
    uint32_t id{};
    for (int64_t i = 0; i < dims[0]; i++) {
      for (int64_t j = 0; j < dims[1]; j++) {
        const auto* cell = mxGetCell(a, j * dims[0] + i);
        if (!cell || mxGetClassID(cell) != mxCHAR_CLASS) {
          mexErrMsgIdAndTxt(err_id(), "Expected cell array of strings.");
        }

        s.resize(mxGetNumberOfElements(cell) + 1);
        if (mxGetString(cell, &s[0], s.size())) {
          mexErrMsgIdAndTxt(err_id(), "Failed to copy string.");
        }

        auto it = strings.find(s);
        uint32_t curr_id;
        if (it == strings.end()) {
          if (id == ~0u) {
            mexErrMsgIdAndTxt(err_id(), "Too many unique strings.");
          } else {
            curr_id = id++;
            strings[s] = curr_id;
          }
        } else {
          curr_id = it->second;
        }

        ids[i * dims[1] + j] = curr_id;
      }
    }
  }
  
  std::string key;
  key.resize(dims[1] * sizeof(uint32_t));
  
  std::unordered_map<std::string, uint64_t> unique_rows;
  uint64_t row_id{};  
  
  auto* ic_array = mxCreateUninitNumericMatrix(
    dims[0], 1, mxDOUBLE_CLASS, mxREAL);
  double* ic = mxGetPr(ic_array);
  
  std::vector<double> ia;  
  for (int64_t i = 0; i < dims[0]; i++) {
    for (int64_t j = 0; j < dims[1]; j++) {
      auto id = ids[i * dims[1] + j];
      memcpy(&key[j * sizeof(uint32_t)], &id, sizeof(uint32_t));
    }
    
    auto it = unique_rows.find(key);
    uint64_t curr_row;
    if (it == unique_rows.end()) {
      curr_row = row_id++;
      unique_rows[key] = curr_row;
      ia.push_back(double(i + 1));
    } else {
      curr_row = it->second;
    }
    
    *ic++ = double(curr_row + 1);
  }
  
  auto* ia_array = mxCreateUninitNumericMatrix(
    int64_t(ia.size()), 1, mxDOUBLE_CLASS, mxREAL);
  double* ia_dst = mxGetPr(ia_array);
  memcpy(ia_dst, ia.data(), ia.size() * sizeof(double));
  
  plhs[0] = ia_array;
  plhs[1] = ic_array;
}