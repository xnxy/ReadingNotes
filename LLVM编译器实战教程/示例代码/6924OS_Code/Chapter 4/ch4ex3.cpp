/// ch4ex3.cpp
/// This file contains the source code for the AST traversal example of Chapter
/// 4. It shows you how to use libclang to traverse the Clang AST with a
/// a callback for each node. 

extern "C" {
#include "clang-c/Index.h"
}
#include "llvm/Support/CommandLine.h"
#include <iostream>

using namespace llvm;

static cl::opt<std::string>
FileName(cl::Positional ,cl::desc("Input file"),
         cl::Required);

enum CXChildVisitResult visitNode (CXCursor cursor, CXCursor parent, 
                                   CXClientData client_data) {
  if (clang_getCursorKind(cursor) == CXCursor_CXXMethod ||
      clang_getCursorKind(cursor) == CXCursor_FunctionDecl) {
    CXString name = clang_getCursorSpelling(cursor);
    CXSourceLocation loc = clang_getCursorLocation (cursor);
    CXString fName;
    unsigned line = 0, col = 0;
    clang_getPresumedLocation(loc, &fName, &line, &col);
    std::cout << clang_getCString(fName) << ":"
              << line << ":" << col << " declares " 
              << clang_getCString(name) << std::endl;
    clang_disposeString(fName); 
    clang_disposeString(name);     
    return CXChildVisit_Continue;
  }
  return CXChildVisit_Recurse;
}

int main(int argc, char** argv)
{
  cl::ParseCommandLineOptions(argc, argv, "AST Traversal Example\n");
  CXIndex index = clang_createIndex(0,0);
  const char *args[] = {
    "-I/usr/include",
    "-I."
  };
  CXTranslationUnit translationUnit = 
    clang_parseTranslationUnit(index, FileName.c_str(),
                               args, 2, NULL, 0, CXTranslationUnit_None);
  CXCursor cur = clang_getTranslationUnitCursor(translationUnit);
  clang_visitChildren(cur, visitNode, NULL);
  clang_disposeTranslationUnit(translationUnit);
  clang_disposeIndex(index);
  return 0;
}
