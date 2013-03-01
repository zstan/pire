%module pire
%{
    #include "pire/re_lexer.h"
    #include "pire/fsm.h"
    #include "pire/encoding.h"
    #include "pire/run.h"

    #include "pire/scanners/multi.h"
    #include "pire/scanners/simple.h"
    #include "pire/scanners/slow.h"
    #include "pire/scanners/pair.h"
%}

%include std_string.i
%include std_vector.i

%rename(operator_content) operator*;
%rename(operator_increment) operator++;
%rename(operator_eq) operator=;

  %template(pire_wchar32_vector) std::vector<uint32_t>;

  struct output_iterator_tag { };

  %rename(voidIter) iterator<output_iterator_tag, void, void, void, void>;
  struct iterator<output_iterator_tag, void, void, void, void> { };
  
  /*%rename (backInsertIterator) back_insert_iterator<std::vector<uint32_t> >;
  class back_insert_iterator<std::vector<uint32_t> >
  {
    protected:
      std::vector<uint32_t>* container;
    public:
      typedef std::vector<uint32_t> container_type;
      explicit back_insert_iterator (container_type& x) : container(&x) {};
      back_insert_iterator& operator= (typename std::vector<uint32_t>::const_reference value);
      back_insert_iterator& operator* ();
      back_insert_iterator& operator++ ();
      back_insert_iterator operator++ (int);
  };*/

template <class Container>
  class back_insert_iterator :
    public iterator<output_iterator_tag,void,void,void,void>
{
protected:
  Container* container;

public:
  typedef Container container_type;
  explicit back_insert_iterator (Container& x) : container(&x) {}
  back_insert_iterator<Container>& operator= (typename Container::const_reference value)
    { container->push_back(value); return *this; }
  back_insert_iterator<Container>& operator* ()
    { return *this; }
  back_insert_iterator<Container>& operator++ ()
    { return *this; }
  back_insert_iterator<Container> operator++ (int)
    { return *this; }
};

  %template (backInsertIterator) back_insert_iterator<std::vector<uint32_t> >;
  

/*  %rename (backInserter) back_insert_iterator<std::vector<uint32_t> >;
  template< class Container >
  std::back_insert_iterator<Container> back_inserter( Container& c)
  {
    return std::back_insert_iterator<Container>(c);
  }
*/
  //back_insert_iterator<Container> back_inserter (Container& x);
  //%template(backInserter) std::back_inserter<std::vector<uint32_t> >;

namespace Pire 
{
	class Fsm {
	public:		
		Fsm();
    Fsm& Surround();
		template<class Scanner> Scanner Compile();
  };

  class Lexer {
  public:
    Lexer();
    explicit Lexer(const char* str);
    ~Lexer();
    const Pire::Encoding& Encoding() const;
    void Assign(std::string::iterator begin, std::string::iterator end);
    Fsm Parse();
  };

  class Encoding 
  {
    public:
      virtual ~Encoding() {}
      virtual void AppendDot(Fsm&) const = 0;

      std::back_insert_iterator<std::vector<uint32_t> > FromLocal(const char* begin, const char* end, std::back_insert_iterator<std::vector<uint32_t> > iter) const;
  };

  class Utf8: public Encoding 
  {
    public:
		  Utf8() : Encoding() {}
		  uint32_t FromLocal(const char*& begin, const char* end) const;
		  void AppendDot(Fsm& fsm) const;
	};

}
  


