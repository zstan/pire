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
/*
  struct output_iterator_tag { };

  %rename(voidIter) iterator<output_iterator_tag, void, void, void, void>;
  struct iterator<output_iterator_tag, void, void, void, void> { };
*/  
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

//
//  class back_insert_iterator :
//    public iterator<output_iterator_tag,void,void,void,void>

namespace std {

template<class _Container>
	class back_insert_iterator
	{	// wrap pushes to back of container as output iterator
public:
	typedef back_insert_iterator<_Container> _Myt;
	typedef _Container container_type;
	typedef typename _Container::const_reference const_reference;
	typedef typename _Container::value_type _Valty;

	explicit back_insert_iterator(_Container& _Cont);
	_Myt& operator=(const _Valty& _Val);

	_Myt& operator*();
	_Myt& operator++();
	_Myt operator++(int);

protected:
	_Container *container;	// pointer to container
	};

  template< class Container >
  std::back_insert_iterator<Container> back_inserter( Container& c)
  {
    return std::back_insert_iterator<Container>(c);
  }
}

  %template (backInsertIterator) std::back_insert_iterator<std::vector<uint32_t> >; 
  %template(backInserter) std::back_inserter<std::vector<uint32_t> >;
  
namespace Pire 
{

namespace Impl {

  template <size_t MaskCount>
  class ExitMasks {
  };  

  %template(MaskCount_2) ExitMasks<2>;

  struct Relocatable {
	};

  template<class Relocation, class Shortcutting>
  class Scanner {
  };

  %template(Scanner_Relocatable) Scanner<Relocatable, ExitMasks<2> >;
}

  typedef Impl::Scanner<Impl::Relocatable, Impl::ExitMasks<2> > Scanner1;

	class Fsm {
	public:		
		Fsm();
    Fsm& Surround();
		template<class T> T Compile();
    //%template(Scanner_Reloc) Compile<Impl::Scanner<Impl::Relocatable, Impl::ExitMasks<2> > >;
    //%template(Scanner_Reloc) Compile<Impl::Scanner<Impl::Relocatable, Impl::ExitMasks<2> > >;
  };
  
%extend Fsm {
     %template(Scanner_Reloc) Compile<Impl::Scanner<Impl::Relocatable, Impl::ExitMasks<2> > >;
}

  typedef std::string ystring;
  typedef unsigned short Char;

  template<class Scanner>
  class RunHelper {
  public:
  	explicit RunHelper(const Scanner& sc): Sc(&sc) { Sc->Initialize(St); }

  	RunHelper<Scanner>& Step(Char letter);
  	RunHelper<Scanner>& Run(const char* begin, const char* end);
  	RunHelper<Scanner>& Run(const char* str, size_t size);
  	RunHelper<Scanner>& Run(const ystring& str);
  	RunHelper<Scanner>& Begin();
  	RunHelper<Scanner>& End();

      %extend {
        bool isOk() const
        {return $self->Sc->Final($self->St);}
      }

  };

  %template (RunHelperImpl) RunHelper<Impl::Scanner<Impl::Relocatable, Impl::ExitMasks<2> > >;

/*  template<class Scanner>
  RunHelper<Scanner> Runner(const Scanner& sc);

  %template (RunnerImpl) Runner<Impl::Scanner<Impl::Relocatable, Impl::ExitMasks<2> > >;
  */

  class Lexer {
  public:
    Lexer();
    explicit Lexer(const char* str);
    ~Lexer();
    const Pire::Encoding& Encoding() const;
    //void Assign(std::vector<uint32_t>::iterator begin, std::vector<uint32_t>::iterator end);
    Fsm Parse();
    //Lexer& AddFeature(Feature* a);
    %extend {
      void assign(const std::vector<uint32_t> v)
      {
        std::vector<uint32_t>::const_iterator begin = v.begin();
        std::vector<uint32_t>::const_iterator end   = v.end();
        //$self->AddFeature(new CharacterRangeReader);
        //$self->AddFeature(new RepetitionCountReader);
        $self->InstallDefaultFeatures();
     		$self->Assign(begin, end);
      }
    } 
  };

  class Encoding 
  {
    public:
      virtual ~Encoding() {}
      virtual void AppendDot(Fsm&) const = 0;

      %extend {
        std::vector<uint32_t> _FromLocal(const std::string &in) const 
        {
          std::vector<uint32_t> ucs4;
          $self->FromLocal(in.c_str(), in.c_str() + strlen(in.c_str()), std::back_inserter(ucs4));
          return ucs4;
        }
      }

    
  };


namespace {
  class Utf8: public Encoding 
  {
    public:
		  Utf8() : Encoding() {}
		  uint32_t FromLocal(const char*& begin, const char* end) const;
		  void AppendDot(Fsm& fsm) const;	

  };

  static const Utf8 utf8;
}

namespace Encodings {
	const Encoding& Utf8();
};


}


  


