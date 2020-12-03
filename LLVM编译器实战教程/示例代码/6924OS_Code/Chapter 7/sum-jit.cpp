/// sum-jit.cpp
/// This file contains the source code for the first example presented in
/// Chapter 7, teaching how to use the llvm::JIT class to generate code to 
/// compile a simple sum.bc bitcode file.

#include "llvm/Bitcode/ReaderWriter.h"
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
  int (*Sum)(int, int) = (int (*)(int,int)) EE->getPointerToFunction(SumFn);
  int res = Sum(4,5);
  outs() << "Sum result: " << res << "\n";
  res = Sum(res, 6);
  outs() << "Sum result: " << res << "\n";

  EE->freeMachineCodeForFunction(SumFn);
  llvm_shutdown();
  return 0;
}
  
