/// hello.cpp
/// This file contains the source code for the example in Chapter 3
/// in charge of reading LLVM bitcode files and printing the name of
/// the functions defined in it.

#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorOr.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

static cl::opt<std::string>
FileName(cl::Positional, cl::desc("Bitcode file"),
         cl::Required);

int main(int argc, char** argv)
{
  cl::ParseCommandLineOptions(argc, argv, "LLVM hello world\n");
  LLVMContext context;

  ErrorOr<std::unique_ptr<MemoryBuffer>> mb = MemoryBuffer::getFile(FileName);
  if (std::error_code ec = mb.getError()) {
    errs() << ec.message();
    return -1;
  }

  ErrorOr<Module *> m = parseBitcodeFile(mb->get(), context);
  if (std::error_code ec = m.getError()) {
    errs() << "Error reading bitcode: " << ec.message() << "\n";
    return -1;
  }

  for (Module::const_iterator I = (*m)->getFunctionList().begin(),
    E = (*m)->getFunctionList().end(); I != E; ++I) {
    if (!I->isDeclaration()) {
      outs() << I->getName() << " has " << I->size() << " basic blocks.\n";
    }
  }

  return 0;
}
