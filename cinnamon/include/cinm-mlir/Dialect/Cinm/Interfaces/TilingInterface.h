#pragma once

#include "mlir/IR/Builders.h"
#include "mlir/IR/OpDefinition.h"

#include <cstdint>
#include <llvm/ADT/ArrayRef.h>
#include <mlir/IR/BuiltinTypes.h>
#include <mlir/IR/Location.h>
#include <mlir/IR/Value.h>
#include <mlir/IR/ValueRange.h>
#include <mlir/Support/LLVM.h>
#include <utility>

namespace mlir::cinm {
struct ComputeOp;
struct TilingParameters {
  /// Maximum size of all buffers inside a compute kernel.
  const int64_t maxBufferSizeInBytes;
  /// Workgroup shape being considered for tiling
  const llvm::ArrayRef<int64_t> workgroupShape;

  TilingParameters(int64_t maxBufferSizeInBytes,
                   llvm::ArrayRef<int64_t> workgroupShape)
      : maxBufferSizeInBytes(maxBufferSizeInBytes),
        workgroupShape(workgroupShape) {}

  /// Return the size of tiles on a reduce dimension.
  /// Computes this by assuming the reduction operation needs (maybe several)
  /// buffers of the same size, same element type. The returned tile size
  /// divides the number of reduced elements.
  int64_t reduceClusterSize(int64_t numBuffers, int64_t reducedElements,
                            Type elementTy);

  /// Determine tiling factors for dimensions n and m.
  std::pair<int64_t, int64_t> parallelClusterSize(int64_t n, int64_t m);

  /// Number of parallel elements in the working group.
  int64_t workingGroupSize();

  int64_t maxNumElementsOfType(Type ty);

  static TilingParameters fromComputeBlock(cinm::ComputeOp &);
};

/// Exclude a cinm op from the --cinm-tiling pass
void markOpAsNoTile(Operation *);

/// Create a tensor.reshape for a fully static tensor shape
Value reshapeStatic(OpBuilder &, Location loc, Value value,
                    RankedTensorType type, llvm::ArrayRef<int64_t> newShape);

/// Create a tensor.reshape for a fully static tensor shape
Value reshapeStatic(OpBuilder &b, Location loc,
                    TypedValue<RankedTensorType> value,
                    llvm::ArrayRef<int64_t> newShape);

using ReduceAccumulatorCallback =
    function_ref<Value(OpBuilder &, Location, Value, Value)>;

template <typename ReductionOp>
Value createVectorReduce(OpBuilder &builder, Location loc, Value vector,
                         Value init, int64_t clusterSize) {
  return createVectorReduce(
      builder, loc, vector, init,
      [](OpBuilder &builder, Location loc, Value lhs, Value rhs) {
        return builder.create<ReductionOp>(loc, lhs, rhs);
      },
      clusterSize);
}

Value createVectorReduce(OpBuilder &builder, Location loc, Value vector,
                         Value init, ReduceAccumulatorCallback callback,
                         int64_t clusterSize = 1);

Value createVectorReduceAdd(OpBuilder &builder, Location loc, Value vector,
                            int64_t clusterSize = 1);

Value createVectorReduceMul(OpBuilder &builder, Location loc, Value vector,
                            int64_t clusterSize = 1);

Value createVectorReduceMin(OpBuilder &builder, Location loc, Value vector,
                            int64_t clusterSize = 1);

Value createVectorReduceMax(OpBuilder &builder, Location loc, Value vector,
                            int64_t clusterSize = 1);

} // namespace mlir::cinm

//===- Generated includes -------------------------------------------------===//

#include "cinm-mlir/Dialect/Cinm/Interfaces/TilingInterface.h.inc"

//===----------------------------------------------------------------------===//