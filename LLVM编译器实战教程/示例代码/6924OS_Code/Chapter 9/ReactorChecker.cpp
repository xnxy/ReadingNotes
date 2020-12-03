/// ReactorChecker.cpp
/// This file contains the source code for the static analyzer checker example
/// presented in Chapter 9.

#include "ClangSACheckers.h"
#include "clang/StaticAnalyzer/Core/BugReporter/BugType.h"
#include "clang/StaticAnalyzer/Core/Checker.h"
#include "clang/StaticAnalyzer/Core/PathSensitive/CallEvent.h"
#include "clang/StaticAnalyzer/Core/PathSensitive/CheckerContext.h"
using namespace clang;
using namespace ento;     

namespace {
class ReactorState {
private:
  enum Kind {Unknown, On, Off} K;
 public:
  ReactorState(unsigned InK): K((Kind) InK) {}
  bool isOn() const { return K == On; }
  bool isOff() const { return K == Off; }
  static unsigned getOn() { return (unsigned) On; }
  static unsigned getOff() { return (unsigned) Off; }
  bool operator==(const ReactorState &X) const {
    return K == X.K;
  }
  void Profile(llvm::FoldingSetNodeID &ID) const {
    ID.AddInteger(K);
  } 
};

class ReactorChecker : public Checker<check::PostCall> {
   mutable IdentifierInfo *IIturnReactorOn, *IISCRAM;
   std::unique_ptr<BugType> DoubleSCRAMBugType;
   std::unique_ptr<BugType> DoubleONBugType;
   void initIdentifierInfo(ASTContext &Ctx) const;
   void reportDoubleSCRAM(const CallEvent &Call,
                          CheckerContext &C) const;
   void reportDoubleON(const CallEvent &Call,
                       CheckerContext &C) const;
 public:
   ReactorChecker();
   /// Process turnReactorOn and SCRAM
   void checkPostCall(const CallEvent &Call, CheckerContext &C) const;
 };
}

REGISTER_MAP_WITH_PROGRAMSTATE(RS, int, ReactorState)

ReactorChecker::ReactorChecker() : IIturnReactorOn(0), IISCRAM(0) {
  // Initialize the bug types.
  DoubleSCRAMBugType.reset(new BugType(this, "Double SCRAM",
                                       "Nuclear Reactor API Error"));
  DoubleONBugType.reset(new BugType(this, "Double ON",
                                    "Nuclear Reactor API Error"));
}

void ReactorChecker::initIdentifierInfo(ASTContext &Ctx) const {
  if (IIturnReactorOn)
    return;
  IIturnReactorOn = &Ctx.Idents.get("turnReactorOn");
  IISCRAM = &Ctx.Idents.get("SCRAM");
}

void ReactorChecker::checkPostCall(const CallEvent &Call,
                                   CheckerContext &C) const {
  initIdentifierInfo(C.getASTContext());
  if (!Call.isGlobalCFunction())
    return;
  if (Call.getCalleeIdentifier() == IIturnReactorOn) {
    ProgramStateRef State = C.getState();
    const ReactorState *S = State->get<RS>(1);
    if (S && S->isOn()) {
      reportDoubleON(Call, C);
      return; 
    }
    State = State->set<RS>(1, ReactorState::getOn());
    C.addTransition(State);
    return;
  }
  if (Call.getCalleeIdentifier() == IISCRAM) {
    ProgramStateRef State = C.getState();
    const ReactorState *S = State->get<RS>(1);
    if (S && S->isOff()) {
      reportDoubleSCRAM(Call, C);
      return; 
    }
    State = State->set<RS>(1, ReactorState::getOff());
    C.addTransition(State);
    return;
  }
}

void ReactorChecker::reportDoubleON(const CallEvent &Call,
                                    CheckerContext &C) const {
  ExplodedNode *ErrNode = C.generateSink();
  if (!ErrNode)
    return;
  BugReport *R = new BugReport(*DoubleONBugType,
                               "Turned on the reactor two times", ErrNode);
  R->addRange(Call.getSourceRange());
  C.emitReport(R);
}

void ReactorChecker::reportDoubleSCRAM(const CallEvent &Call,
                                       CheckerContext &C) const {
  ExplodedNode *ErrNode = C.generateSink();
  if (!ErrNode)
    return;
  BugReport *R = new BugReport(*DoubleSCRAMBugType,
                               "Called a SCRAM procedure twice", ErrNode);
  R->addRange(Call.getSourceRange());
  C.emitReport(R);
}

void ento::registerReactorChecker(CheckerManager &mgr) {
  mgr.registerChecker<ReactorChecker>(); 
}

