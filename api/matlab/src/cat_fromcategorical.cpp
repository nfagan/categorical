#include "cat_api.hpp"
#include <unordered_map>

//
//  NOTE: The majority of input checking for this function is done on the
//      m-file side of things. Do not attempt to call this function directly!
//

void util::from_matlab_categorical(util::categorical* self,
                                        const std::vector<std::string>& categories,
                                        const std::vector<std::string>& labels,
                                        util::u32* lab_ids,
                                        util::u64 rows,
                                        util::u64 cols)
{
    using namespace util;
    
    for (u64 i = 0; i < cols; i++)
    {
        self->add_category(categories[i]);
    }
    
    self->resize(rows);
    
    std::unordered_map<u32, u32> visited;
    
    u32 max = 0;
    
    for (u64 i = 0; i < cols; i++)
    {
        const std::string& category = categories[i];
        
        std::vector<u32>& dest = self->m_labels[i];
        
        for (u64 j = 0; j < rows; j++)
        {
            u32 val = lab_ids[j + i * rows];
            
            if (visited.count(val) > 0)
            {
                if (visited[val] != i)
                {
                    delete self;
                    mexErrMsgIdAndTxt("categorical:fromcategorical", 
                            get_error_text_label_exists().c_str());
                }
                
                dest[j] = val;
                
                continue;
            }
            
            const std::string& lab = labels[val-1];

            if (self->m_collapsed_expressions.count(lab) > 0)
            {
                if (self->get_collapsed_expression(category) != lab)
                {
                    delete self;
                    mexErrMsgIdAndTxt("categorical:fromcategorical", 
                            get_error_text_label_exists().c_str());
                }
            }

            self->m_label_ids.insert(lab, val);
            self->m_in_category[lab] = category;

            visited[val] = i;

            if (val > max)
            {
                max = val;
            }
            
            dest[j] = val;
        }
    }
    
    self->m_next_id = max + 2;
}

void util::from_categorical(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using namespace util;
    using std::vector;
    
    const char* func_id = "categorical:fromcategorical";
    
    assert_nrhs(nrhs, 4, func_id);
    assert_nlhs(nlhs, 1, func_id);
    
    categorical* cat = new categorical();
    
    vector<std::string> categories = get_strings(prhs[1], func_id);
    vector<std::string> labels = get_strings(prhs[2], func_id);
    vector<u32> ids = numeric_array_to_vector32(prhs[3], func_id);
    
    u64 n_ids = ids.size();
    u64 cols = categories.size();
    u64 rows = n_ids / cols;
    
    from_matlab_categorical(cat, categories, labels, ids.data(), rows, cols);
    
    plhs[0] = detail::ptr_to_mat<categorical>(cat);
}