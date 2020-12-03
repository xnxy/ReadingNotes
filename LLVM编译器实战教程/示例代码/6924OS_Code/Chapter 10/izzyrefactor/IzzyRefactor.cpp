/// IzzyRefactor.cpp
/// This file contains the source code for the refactoring tool example 
/// presented in Chapter 10.

#include "llvm/Support/CommandLine.h"
#include "clang/Tooling/CompilationDatabase.h"
#include "llvm/Support/ErrorHandling.h"
#include "clang/ASTMatchers/ASTMatchers.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "clang/Tooling/Refactoring.h"

using namespace clang;
using namespace llvm;
using namespace std;
using namespace clang::ast_matchers;
using clang::tooling::RefactoringTool;
using clang::tooling::Replacement;
using clang::tooling::CompilationDatabase;
using clang::tooling::newFrontendActionFactory;

namespace {
cl::opt<string> BuildPath(
  cl::Positional,
  cl::desc("<build-path>"));
cl::list<string> SourcePaths(
  cl::Positional,
  cl::desc("<source0> [... <sourceN>]"),
  cl::OneOrMore);
cl::opt<string> OriginalMethodName("method", cl::ValueRequired,
  cl::desc("Method name to replace"));
cl::opt<string> ClassName("class", cl::ValueRequired,
  cl::desc("Name of the class that has this method"),
  cl::ValueRequired);
cl::opt<string> NewMethodName("newname",
  cl::desc("New method name"),
  cl::ValueRequired);


class ChangeMemberDecl : public ast_matchers::MatchFinder::MatchCallback{
  tooling::Replacements *Replace;
public:
  ChangeMemberDecl(tooling::Replacements *Replace) : Replace(Replace) {}
  virtual void run(const ast_matchers::MatchFinder::MatchResult &Result) {
    const CXXMethodDecl *method = 
      Result.Nodes.getNodeAs<CXXMethodDecl>("methodDecl");
    Replace->insert(Replacement(
      *Result.SourceManager,
      CharSourceRange::getTokenRange(
        SourceRange(method->getLocation())), NewMethodName));
  }
};

class ChangeMemberCall : public ast_matchers::MatchFinder::MatchCallback{
  tooling::Replacements *Replace;
public:
  ChangeMemberCall(tooling::Replacements *Replace) : Replace(Replace) {}
  virtual void run(const ast_matchers::MatchFinder::MatchResult &Result) {
    const MemberExpr *member = 
      Result.Nodes.getNodeAs<MemberExpr>("member");
    Replace->insert(Replacement(
      *Result.SourceManager,
      CharSourceRange::getTokenRange(
        SourceRange(member->getMemberLoc())), NewMethodName));
  }
};
}

int main(int argc, char **argv) {
  cl::ParseCommandLineOptions(argc, argv);
  string ErrorMessage;
  std::unique_ptr<CompilationDatabase> Compilations (
    CompilationDatabase::loadFromDirectory(
      BuildPath, ErrorMessage));
  if (!Compilations)
    report_fatal_error(ErrorMessage);  
  RefactoringTool Tool(*Compilations, SourcePaths);
  ast_matchers::MatchFinder Finder;
  ChangeMemberDecl Callback1(&Tool.getReplacements());
  ChangeMemberCall Callback2(&Tool.getReplacements());
  Finder.addMatcher(
    recordDecl(
      allOf(hasMethod(id("methodDecl", 
                        methodDecl(hasName(OriginalMethodName)))),
        isSameOrDerivedFrom(hasName(ClassName)))),
    &Callback1);
  Finder.addMatcher(
    memberCallExpr(
      callee(id("member",  
                memberExpr(member(hasName(OriginalMethodName))))), 
      thisPointerType(recordDecl(
        isSameOrDerivedFrom(hasName(ClassName))))),
    &Callback2);
  return Tool.runAndSave(newFrontendActionFactory(&Finder).get());
}

