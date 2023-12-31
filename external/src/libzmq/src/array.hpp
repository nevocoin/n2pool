/* SPDX-License-Identifier: MPL-2.0 */

#ifndef __ZMQ_ARRAY_INCLUDED__
#define __ZMQ_ARRAY_INCLUDED__

#include <vector>
#include <algorithm>

#include "macros.hpp"

namespace zmq
{
//  Implementation of fast arrays with O(1) access, insertion and
//  removal. The array stores pointers rather than objects.
//  O(1) is achieved by making items inheriting from
//  array_item_t<ID> class which internally stores the position
//  in the array.
//  The ID template argument is used to differentiate among arrays
//  and thus let an object be stored in different arrays.

//  Base class for objects stored in the array. If you want to store
//  same object in multiple arrays, each of those arrays has to have
//  different ID. The item itself has to be derived from instantiations of
//  array_item_t template for all relevant IDs.

template <int ID = 0> class array_item_t
{
  public:
    array_item_t () : _array_index (-1) {}

    //  The destructor doesn't have to be virtual. It is made virtual
    //  just to keep ICC and code checking tools from complaining.
    virtual ~array_item_t () ZMQ_DEFAULT;

    void set_array_index (int index_) { _array_index = index_; }

    int get_array_index () const { return _array_index; }

  private:
    int _array_index;

    ZMQ_NON_COPYABLE_NOR_MOVABLE (array_item_t)
};


template <typename T, int ID = 0> class array_t
{
  private:
    typedef array_item_t<ID> item_t;

  public:
    typedef typename std::vector<T *>::size_type size_type;

    array_t () ZMQ_DEFAULT;

    size_type size () { return _items.size (); }

    bool empty () { return _items.empty (); }

    T *&operator[] (size_type index_) { return _items[index_]; }

    void push_back (T *item_)
    {
        if (item_)
            static_cast<item_t *> (item_)->set_array_index (
              static_cast<int> (_items.size ()));
        _items.push_back (item_);
    }

    void erase (T *item_)
    {
        erase (static_cast<item_t *> (item_)->get_array_index ());
    }

    void erase (size_type index_)
    {
        if (_items.empty ())
            return;
        static_cast<item_t *> (_items.back ())
          ->set_array_index (static_cast<int> (index_));

        _items[index_] = _items.back ();
        _items.pop_back ();
    }

    void swap (size_type index1_, size_type index2_)
    {
        if (_items[index1_])
            static_cast<item_t *> (_items[index1_])
              ->set_array_index (static_cast<int> (index2_));
        if (_items[index2_])
            static_cast<item_t *> (_items[index2_])
              ->set_array_index (static_cast<int> (index1_));
        std::swap (_items[index1_], _items[index2_]);
    }

    void clear () { _items.clear (); }

    static size_type index (T *item_)
    {
        return static_cast<size_type> (
          static_cast<item_t *> (item_)->get_array_index ());
    }

  private:
    typedef std::vector<T *> items_t;
    items_t _items;

    ZMQ_NON_COPYABLE_NOR_MOVABLE (array_t)
};
}

#endif
