//=============================================================================
// FILE:
//    HelloWorld.cpp
//
// DESCRIPTION:
//    Visits all functions in a module, prints their names and the number of
//    arguments via stderr. Strictly speaking, this is an analysis pass (i.e.
//    the functions are not modified). However, in order to keep things simple
//    there's no 'print' method here (every analysis pass should implement it).
//
// USAGE:
//    New PM
//      opt -load-pass-plugin=libHelloWorld.dylib -passes="hello-world" `\`
//        -disable-output <input-llvm-file>
//
//
// License: MIT
//=============================================================================
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include <cassert>
#include <llvm-18/llvm/IR/Constant.h>
#include <llvm-18/llvm/IR/Instruction.h>
#include <llvm-18/llvm/Support/Casting.h>

using namespace llvm;

//-----------------------------------------------------------------------------
// HelloWorld implementation
//-----------------------------------------------------------------------------
// No need to expose the internals of the pass to the outside world - keep
// everything in an anonymous namespace.
namespace {

// New PM implementation
struct HelloWorld : PassInfoMixin<HelloWorld> {
  bool ConstantsAdded = false;
  Constant *XorMask64;
  Constant *XorMask32;
  Constant *XorMask16;
  Constant *XorMask8;

  void addConstants(Function &F){
      // Add Global Values with only ones to the module
      Module &M = *F.getParent();
       XorMask64 = M.getOrInsertGlobal("XorMask64", Type::getInt64Ty(F.getContext()));
       XorMask32 = M.getOrInsertGlobal("XorMask32", Type::getInt32Ty(F.getContext()));
       XorMask16 = M.getOrInsertGlobal("XorMask16", Type::getInt16Ty(F.getContext()));
       XorMask8 = M.getOrInsertGlobal("XorMask8", Type::getInt8Ty(F.getContext()));
      ConstantsAdded = true;}
  // Main entry point, takes IR unit to run the pass on (&F) and the
  // corresponding pass manager (to be queried if need be)
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {
    // TODO The IRBuilder uses Constant folding on the XorInstruction and will fail on all Constants, if the masks are changed.
    if (!ConstantsAdded)
      addConstants(F);
    // TODO Load value from XorMask64, as it is now a constant and not an immediate, as it was before.

    // iterate over the basic blocks in the function
    for (auto &BB : F) {
      // iterate over the instructions in the basic block
      for (auto &I : BB) {
        // Handle Loads
        if (I.getOpcode() == Instruction::Load) {
          // Cast I to llvm::Value
          LoadInst *LoadOp = dyn_cast<LoadInst>(&I);
          // Create IRBuilder
          IRBuilder<> Builder(&I);
          // Add new Instructions after LoadOp
          Builder.SetInsertPoint(I.getNextNode());
          bool isPointer = I.getType()->isPointerTy();
          // Create XorMask based on the type of the loaded value
          Constant *XorMask = nullptr;
          Type *CurrentType = nullptr;
          if (I.getType()->isIntegerTy(64) || I.getType()->isPointerTy()) {
            XorMask = XorMask64;
            CurrentType = Type::getInt64Ty(F.getContext());
          } else if (I.getType()->isIntegerTy(32)) {
            XorMask = XorMask32;
            CurrentType = Type::getInt32Ty(F.getContext());
          } else if (I.getType()->isIntegerTy(16)) {
            XorMask = XorMask16;
            CurrentType = Type::getInt16Ty(F.getContext());
          } else if (I.getType()->isIntegerTy(8)) {
            XorMask = XorMask8;
            CurrentType = Type::getInt8Ty(F.getContext());
          }
          // XorMask and CurrentType have to be set at this point!
          assert(XorMask != nullptr && "Failed to create XorMask");
          assert(CurrentType != nullptr && "Failed to set CurrentType");
          // Bitcast loaded value to i64
          bool CastInst0Set = false;
          Value *CastInst0 = nullptr;
          if (isPointer) {
            CastInst0Set = true;
            CastInst0 = Builder.CreatePtrToInt(
                LoadOp, Type::getInt64Ty(F.getContext()));
          } else if (LoadOp->getType() != CurrentType) {
            CastInst0Set = true;
            CastInst0 = Builder.CreateZExtOrBitCast(LoadOp, CurrentType);
          }
          if (CastInst0Set)
            assert(CastInst0 != nullptr && "Failed to create CastInst0");
          // errs() << "(llvm-tutor)   instruction: \033[1;31m" << *CastInst0
          //        << "\033[0m\n";
          // add xor instruction, which xors the loaded value with the XorMask
          Value *XorInst = nullptr;
          if (CastInst0Set)
            XorInst = Builder.CreateXor(CastInst0, XorMask);
          else
            XorInst = Builder.CreateXor(LoadOp, XorMask);
          assert(XorInst != nullptr && "Failed to create XorInst");
          // errs() << "(llvm-tutor)   instruction: \033[1;31m" << *XorInst
          //        << "\033[0m\n";
          // cast the result of the xor operation back to the original type
          bool CastInst1Set = false;
          Value *CastInst1 = nullptr;
          if (isPointer) {
            CastInst1Set = true;
            CastInst1 = Builder.CreateIntToPtr(XorInst, I.getType());
          } else if (LoadOp->getType() != CurrentType) {
            CastInst1Set = true;
            CastInst1 = Builder.CreateBitCast(XorInst, I.getType());
          }
          if (CastInst1Set)
            assert(CastInst1 != nullptr && "Failed to create CastInst1");
          // errs() << "(llvm-tutor)   instruction: \033[1;31m" << *CastInst1
          //        << "\033[0m\n";
          // Replace all uses of I with CastInst1 or XorInst
          // Iterate over all uses of LoadOp
          for (auto U = LoadOp->use_begin(), E = LoadOp->use_end(); U != E;
               ++U) {
            // Replace all uses of LoadOp with CastInst1
            if (U->getUser() == XorInst || U->getUser() == CastInst0)
              continue;
            if (CastInst1Set)
              U->set(CastInst1);
            else
              U->set(XorInst);
            // errs() << "\n";
          }
        } else if (I.getOpcode() == Instruction::Store) {
          if (!ConstantsAdded)
            addConstants(F);
          // Cast I to llvm::Value
          StoreInst *StoreOp = dyn_cast<StoreInst>(&I);
          // Print StoreOp
          errs() << "(llvm-tutor)   instructionPre: \033[1;31m" << *StoreOp
                 << "\033[0m\n";

          // Create IRBuilder
          IRBuilder<> Builder(&I);
          // Check if I is of pointer type
          bool isPointer = StoreOp->getValueOperand()->getType()->isPointerTy();
          // Create XorMask based on the type of the loaded value
          Constant *XorMask = nullptr;
          Type *CurrentType = nullptr;
          if (StoreOp->getValueOperand()->getType()->isIntegerTy(64) ||
              isPointer) {
            XorMask = XorMask64;
            CurrentType = Type::getInt64Ty(F.getContext());
          } else if (StoreOp->getValueOperand()->getType()->isIntegerTy(32)) {
            XorMask = XorMask32;
            CurrentType = Type::getInt32Ty(F.getContext());
          } else if (StoreOp->getValueOperand()->getType()->isIntegerTy(16)) {
            XorMask = XorMask16;
            CurrentType = Type::getInt16Ty(F.getContext());
          } else if (StoreOp->getValueOperand()->getType()->isIntegerTy(8)) {
            XorMask = XorMask8;
            CurrentType = Type::getInt8Ty(F.getContext());
          }
          // XorMask and CurrentType have to be set at this point!
          assert(XorMask != nullptr && "Failed to create XorMask");
          assert(CurrentType != nullptr && "Failed to set CurrentType");
          // Flip Word before it is stored.
          // 1. Cast to Inttype
          // 2. Xor with XorMask
          // 3. Cast back to original type
          // 4. change Stored value with the flipped Value

          // Cast StoreOp to IntType
          bool CastInst0Set = false;
          Value *CastInst0 = nullptr;
          if (isPointer) {
            CastInst0Set = true;
            CastInst0 = Builder.CreatePtrToInt(
                StoreOp->getValueOperand(), Type::getInt64Ty(F.getContext()));
          } else if (StoreOp->getValueOperand()->getType() != CurrentType) {
            CastInst0Set = true;
            CastInst0 = Builder.CreateZExtOrBitCast(StoreOp->getValueOperand(),
                                                    CurrentType);
          }
          if (CastInst0Set)
            assert(CastInst0 != nullptr && "Failed to create CastInst0");

          // add xor instruction, which xors the loaded value with the XorMask
          Value *XorInst = nullptr;
          if (CastInst0Set)
            XorInst = Builder.CreateXor(CastInst0, XorMask);
          else
            XorInst = Builder.CreateXor(StoreOp->getValueOperand(), XorMask);
          assert(XorInst != nullptr && "Failed to create XorInst");

          // cast the result of the xor operation back to the original type
          bool CastInst1Set = false;
          Value *CastInst1 = nullptr;
          if (isPointer) {
            CastInst1Set = true;
            CastInst1 = Builder.CreateIntToPtr(
                XorInst, StoreOp->getValueOperand()->getType());
          } else if (StoreOp->getValueOperand()->getType() != CurrentType) {
            CastInst1Set = true;
            CastInst1 = Builder.CreateBitCast(
                XorInst, StoreOp->getValueOperand()->getType());
          }
          if (CastInst1Set)
            assert(CastInst1 != nullptr && "Failed to create CastInst1");

          // Replace Store Value with CastInst1 or XorInst
          if (CastInst1Set)
            StoreOp->setOperand(0, CastInst1);
          else
            StoreOp->setOperand(0, XorInst);
          // Print StoreOp After changes
          errs() << "(llvm-tutor)   instructionPost: \033[1;31m" << *StoreOp
                 << "\033[0m\n\n";
        }
      }
    }

    return PreservedAnalyses::all();
  }

  // Without isRequired returning true, this pass will be skipped for
  // functions decorated with the optnone LLVM attribute. Note that clang -O0
  // decorates all functions with optnone.
  static bool isRequired() { return true; }
};
} // namespace

//-----------------------------------------------------------------------------
// New PM Registration
//-----------------------------------------------------------------------------
llvm::PassPluginLibraryInfo getHelloWorldPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "HelloWorld", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "hello-world") {
                    FPM.addPass(HelloWorld());
                    return true;
                  }
                  return false;
                });
          }};
}

// This is the core interface for pass plugins. It guarantees that 'opt' will
// be able to recognize HelloWorld when added to the pass pipeline on the
// command line, i.e. via '-passes=hello-world'
extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return getHelloWorldPluginInfo();
}
