#include "categorical.hpp"
#include <iostream>
#include <assert.h>

void test_instantiation();
void test_require_category();
void test_find_allc();
void test_set_category();
void test_append();

int main(int argc, char* argv[])
{
    std::cout << "BEGIN CATEGORICAL" << std::endl;

    test_append();
	test_instantiation();
    test_set_category();
    test_require_category();
    test_find_allc();
    
    std::cout << "END CATEGORICAL" << std::endl;

	return 0;
}

void test_append()
{
    using util::categorical;
    using util::u64;
    using util::u32;
    
    std::vector<std::string> full_cat1 = { "1", "2", "4", "5" };
    std::vector<std::string> full_cat2 = { "a", "b", "c", "d" };
    std::vector<std::string> full_cat3 = { "A", "Z", "X", "T" };
    std::vector<std::string> full_cat4 = { "T", "B", "C", "Y" };
    
    std::vector<std::vector<std::string>> full_cats = { full_cat1, full_cat2, full_cat3, full_cat4 };
    
    categorical cats1;
    categorical cats2;
    
    cats1.require_category("test1");
    cats1.require_category("test2");
    cats2.require_category("test1");
    cats2.require_category("test2");
    
    cats1.set_category("test1", full_cat1);
    cats2.set_category("test1", full_cat2);
    cats1.set_category("test2", full_cat3);
    cats2.set_category("test2", full_cat4);
    
    u32 res = cats1.append(cats2);
    
    assert(res == util::categorical_status::OK);
    assert(cats1.size() == full_cat1.size() * 2);
    
    for (u64 i = 0; i < full_cats.size(); i++)
    {
        const std::vector<std::string>& labs = full_cats[i];
        
        for (u64 j = 0; j < labs.size(); j++)
        {
            assert(cats1.has_label(labs[j]));
        }
    }
    
    std::cout << "OK: test_append" << std::endl;
}

void test_set_category()
{
    using util::categorical;
    using util::u32;
    
    categorical cats;
    
    std::vector<std::string> full_cat = { "test1", "test2" };
    
    std::string cat = "test1";
    
    cats.require_category(cat);
    
    u32 res = cats.set_category(cat, full_cat);
    
    assert(res == util::categorical_status::OK);
    
    assert(cats.has_label("test1"));
    assert(cats.has_label("test2"));
    
    std::cout << "OK: test_set_category" << std::endl;
}

void test_find_allc()
{
    using util::u64;
    using util::u32;
    
    util::categorical cats;
    
    std::vector<std::string> search_cats = { "test1", "test2" };
    
    util::combinations_t result = cats.find_allc(search_cats);
    
    assert(result.indices.size() == 0);
    assert(result.combinations.size() == 0);
    
    cats.require_category("test1");
    
    result = cats.find_allc(search_cats);
    
    assert(result.indices.size() == 0);
    assert(result.combinations.size() == 0);
    
    cats.set_category("test1", search_cats);
    
    std::vector<std::string> search_cat = { "test1" };
    
    result = cats.find_allc(search_cat);
    
    assert(result.indices.size() == 2);
    assert(result.combinations.size() == 2);
    
    
    util::categorical cats2;
    
    cats2.require_category("hi");
    cats2.require_category("sup");
    
    u64 sz = 1e6;
    std::vector<std::string> hi_labs(sz);
    std::vector<std::string> sup_labs(sz);
    
    for (u64 i = 0; i < sz; i++)
    {
        hi_labs[i] = "hello";
        sup_labs[i] = "sup2";
    }
    
    u32 status = cats2.set_category("hi", hi_labs);
    assert(status == util::categorical_status::OK);
    
    status = cats2.set_category("sup", sup_labs);
    assert(status == util::categorical_status::OK);
    
    result = cats2.find_allc({"hi", "sup"});
    result = cats2.find_allc({"hi", "sup"});
    result = cats2.find_allc({"hi", "sup"});
    
    assert(result.indices.size() == 1);
    assert(result.combinations.size() == 2);
    assert(result.indices[0].size() == sz);
    
    for (u64 i = 0; i < sz; i++)
    {
        assert(result.indices[0][i] == i);
    }
    
    std::cout << "OK: test_find_allc" << std::endl;
}

void test_require_category()
{
    using util::u32;
    
    util::categorical cats;
    
    std::string cat = "hi";
    
    cats.require_category(cat);
    
    assert(cats.has_category(cat));
    
    assert(cats.size() == 0);
    
    u32 res = cats.add_category(cat);
    
    assert(res == util::categorical_status::CATEGORY_EXISTS);
    
    std::cout << "OK: test_require_category" << std::endl;
}

void test_instantiation()
{
	util::categorical cats;
}
