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
%include "typemaps.i"

%template(pire_wchar32_vector) std::vector<uint32_t>;

namespace Pire 
{

namespace Impl 
{

  template <size_t MaskCount>
  class ExitMasks {
  };  

  struct Relocatable {
  };

  template<class Relocation, class Shortcutting>
  class Scanner {
    typedef unsigned int State;
    public:
      void Initialize(State &INPUT) const;
  };

  %template(MaskCount_2) ExitMasks<2>;
  %template(Scanner_Relocatable) Scanner<Relocatable, ExitMasks<2> >;
}

  class Fsm {
  public:   
    Fsm();
    Fsm& Surround();
    template<class T> T Compile();
  };
  
  %extend Fsm 
  {
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
      bool isOk() const { return !$self->operator!(); }
    }

  };

  %template (RunHelperImpl) RunHelper<Impl::Scanner<Impl::Relocatable, Impl::ExitMasks<2> > >;

  class Lexer {
  public:
    Lexer();
    explicit Lexer(const char* str);
    ~Lexer();
    const Pire::Encoding& Encoding() const;
    Fsm Parse();
    Lexer& SetEncoding(const Pire::Encoding& encoding);
    //Lexer& AddFeature(Feature* a);
    %extend {
      void assign(const std::vector<uint32_t> v)
      {
        $self->Assign(v.begin(), v.end());
      }
    } 
  };

  class Encoding 
  {
    public:
      virtual ~Encoding() {}
      virtual void AppendDot(Fsm&) const = 0;

      %extend {
        std::vector<uint32_t> FromLocal(const std::string &in) const 
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


  


