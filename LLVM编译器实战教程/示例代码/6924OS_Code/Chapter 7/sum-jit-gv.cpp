/// sum-jit-gv.cpp
/// This file contains the source code for the second example presented in
/// Chapter 7, teaching how to use the GenericValues to simplify calls to jitted
/// functions. 

#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/JIT.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/ErrorOr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/TargetSelect.h"

using namespace llvm;

int main() {
  InitializeNativeTarget();
  LLVMContext Context;

  ErrorOr<std::unique_ptr<MemoryBuffer>> Buffer = MemoryBuffer::getFile("./sum.bc");
  if (Buffer.getError()) {
    errs() << "sum.bc not found\n";
    return -1;
  }

  ErrorOr<Module *> M = parseBitcodeFile(Buffer->get(), Context);
  if (std::error_code ec = M.getError()) {
    errs() << "Error reading bitcode: " << ec.message() << "\n";
    return -1;
  }

  std::unique_ptr<ExecutionEngine> EE(EngineBuilder(*M).create());
  Function *SumFn = (*M)->getFunction("sum");

  std::vector<GenericValue> FnArgs(2);
  FnArgs[0].IntVal = APInt(32,4);
  FnArgs[1].IntVal = APInt(32,5);
  GenericValue Res = EE->runFunction(SumFn, FnArgs);
  outs() << "Sum result: " << Res.IntVal << "\n";
  
  FnArgs[0].IntVal = Res.IntVal;
  FnArgs[1].IntVal = APInt(32,6);
  Res = EE->runFunction(SumFn, FnArgs);
  outs() << "Sum result: " << Res.IntVal << "\n";

  EE->freeMachineCodeForFunction(SumFn);
  llvm_shutdown();
  return 0;
}
