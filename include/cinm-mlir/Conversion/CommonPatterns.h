#pragma once

#include "cinm-mlir/Dialect/Cinm/IR/CinmOps.h"
#include "cinm-mlir/Dialect/Cnm/IR/CnmOps.h"

#include <llvm/ADT/ArrayRef.h>
#include <llvm/ADT/STLExtras.h>

#include <mlir/IR/Builders.h>
#include <mlir/IR/Location.h>
#include <mlir/IR/OpDefinition.h>
#include <mlir/IR/ValueRange.h>
#include <mlir/Support/LLVM.h>
#include <mlir/Transforms/DialectConversion.h>

namespace mlir {

using BodyBuilderCallback = function_ref<SmallVector<Value>(
    OpBuilder &, Location, ValueRange, ValueRange)>;

SmallVector<Value> createNestedAffineForLoops(OpBuilder &builder, Location loc,
                                              ArrayRef<int64_t> loopSizes,
                                              ArrayRef<int64_t> loopSteps,
                                              ValueRange iterArgInit,
                                              BodyBuilderCallback bodyBuilder);

struct ConvertCnmSetZeroToAffine : public OpConversionPattern<cnm::SetZeroOp> {
  ConvertCnmSetZeroToAffine(MLIRContext *context, PatternBenefit benefit = 1);

  LogicalResult matchAndRewrite(cnm::SetZeroOp, OpAdaptor,
                                ConversionPatternRewriter &) const override;
};

} // namespace mlir