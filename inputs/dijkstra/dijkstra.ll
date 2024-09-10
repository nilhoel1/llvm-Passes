; ModuleID = 'dijkstra.c'
source_filename = "dijkstra.c"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

%struct._QITEM = type { i32, i32, i32, ptr }
%struct._NODE = type { i32, i32 }

@dijkstra_checksum = dso_local global i32 0, align 4
@dijkstra_AdjMatrix = external global [100 x [100 x i8]], align 1
@dijkstra_queueCount = dso_local global i32 0, align 4
@dijkstra_queueNext = dso_local global i32 0, align 4
@dijkstra_queueHead = dso_local global ptr null, align 8
@dijkstra_queueItems = dso_local global [1000 x %struct._QITEM] zeroinitializer, align 8
@dijkstra_rgnNodes = dso_local global [100 x %struct._NODE] zeroinitializer, align 4

; Function Attrs: noinline nounwind uwtable
define dso_local void @dijkstra_init() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store volatile i32 0, ptr %3, align 4
  store i32 0, ptr %1, align 4
  br label %4

4:                                                ; preds = %27, %0
  %5 = load i32, ptr %1, align 4
  %6 = icmp slt i32 %5, 100
  br i1 %6, label %7, label %30

7:                                                ; preds = %4
  store i32 0, ptr %2, align 4
  br label %8

8:                                                ; preds = %23, %7
  %9 = load i32, ptr %2, align 4
  %10 = icmp slt i32 %9, 100
  br i1 %10, label %11, label %26

11:                                               ; preds = %8
  %12 = load volatile i32, ptr %3, align 4
  %13 = load i32, ptr %1, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds [100 x [100 x i8]], ptr @dijkstra_AdjMatrix, i64 0, i64 %14
  %16 = load i32, ptr %2, align 4
  %17 = sext i32 %16 to i64
  %18 = getelementptr inbounds [100 x i8], ptr %15, i64 0, i64 %17
  %19 = load i8, ptr %18, align 1
  %20 = zext i8 %19 to i32
  %21 = xor i32 %20, %12
  %22 = trunc i32 %21 to i8
  store i8 %22, ptr %18, align 1
  br label %23

23:                                               ; preds = %11
  %24 = load i32, ptr %2, align 4
  %25 = add nsw i32 %24, 1
  store i32 %25, ptr %2, align 4
  br label %8, !llvm.loop !6

26:                                               ; preds = %8
  br label %27

27:                                               ; preds = %26
  %28 = load i32, ptr %1, align 4
  %29 = add nsw i32 %28, 1
  store i32 %29, ptr %1, align 4
  br label %4, !llvm.loop !8

30:                                               ; preds = %4
  store i32 0, ptr @dijkstra_queueCount, align 4
  store i32 0, ptr @dijkstra_queueNext, align 4
  store ptr null, ptr @dijkstra_queueHead, align 8
  store i32 0, ptr @dijkstra_checksum, align 4
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @dijkstra_return() #0 {
  %1 = load i32, ptr @dijkstra_checksum, align 4
  %2 = icmp eq i32 %1, 25
  %3 = zext i1 %2 to i64
  %4 = select i1 %2, i32 0, i32 -1
  ret i32 %4
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @dijkstra_enqueue(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca ptr, align 8
  %9 = alloca ptr, align 8
  store i32 %0, ptr %5, align 4
  store i32 %1, ptr %6, align 4
  store i32 %2, ptr %7, align 4
  %10 = load i32, ptr @dijkstra_queueNext, align 4
  %11 = sext i32 %10 to i64
  %12 = getelementptr inbounds [1000 x %struct._QITEM], ptr @dijkstra_queueItems, i64 0, i64 %11
  store ptr %12, ptr %8, align 8
  %13 = load ptr, ptr @dijkstra_queueHead, align 8
  store ptr %13, ptr %9, align 8
  %14 = load i32, ptr @dijkstra_queueNext, align 4
  %15 = add nsw i32 %14, 1
  store i32 %15, ptr @dijkstra_queueNext, align 4
  %16 = icmp sge i32 %15, 1000
  br i1 %16, label %17, label %18

17:                                               ; preds = %3
  store i32 -1, ptr %4, align 4
  br label %51

18:                                               ; preds = %3
  %19 = load i32, ptr %5, align 4
  %20 = load ptr, ptr %8, align 8
  %21 = getelementptr inbounds %struct._QITEM, ptr %20, i32 0, i32 0
  store i32 %19, ptr %21, align 8
  %22 = load i32, ptr %6, align 4
  %23 = load ptr, ptr %8, align 8
  %24 = getelementptr inbounds %struct._QITEM, ptr %23, i32 0, i32 1
  store i32 %22, ptr %24, align 4
  %25 = load i32, ptr %7, align 4
  %26 = load ptr, ptr %8, align 8
  %27 = getelementptr inbounds %struct._QITEM, ptr %26, i32 0, i32 2
  store i32 %25, ptr %27, align 8
  %28 = load ptr, ptr %8, align 8
  %29 = getelementptr inbounds %struct._QITEM, ptr %28, i32 0, i32 3
  store ptr null, ptr %29, align 8
  %30 = load ptr, ptr %9, align 8
  %31 = icmp ne ptr %30, null
  br i1 %31, label %34, label %32

32:                                               ; preds = %18
  %33 = load ptr, ptr %8, align 8
  store ptr %33, ptr @dijkstra_queueHead, align 8
  br label %48

34:                                               ; preds = %18
  br label %35

35:                                               ; preds = %40, %34
  %36 = load ptr, ptr %9, align 8
  %37 = getelementptr inbounds %struct._QITEM, ptr %36, i32 0, i32 3
  %38 = load ptr, ptr %37, align 8
  %39 = icmp ne ptr %38, null
  br i1 %39, label %40, label %44

40:                                               ; preds = %35
  %41 = load ptr, ptr %9, align 8
  %42 = getelementptr inbounds %struct._QITEM, ptr %41, i32 0, i32 3
  %43 = load ptr, ptr %42, align 8
  store ptr %43, ptr %9, align 8
  br label %35, !llvm.loop !9

44:                                               ; preds = %35
  %45 = load ptr, ptr %8, align 8
  %46 = load ptr, ptr %9, align 8
  %47 = getelementptr inbounds %struct._QITEM, ptr %46, i32 0, i32 3
  store ptr %45, ptr %47, align 8
  br label %48

48:                                               ; preds = %44, %32
  %49 = load i32, ptr @dijkstra_queueCount, align 4
  %50 = add nsw i32 %49, 1
  store i32 %50, ptr @dijkstra_queueCount, align 4
  store i32 0, ptr %4, align 4
  br label %51

51:                                               ; preds = %48, %17
  %52 = load i32, ptr %4, align 4
  ret i32 %52
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @dijkstra_dequeue(ptr noundef %0, ptr noundef %1, ptr noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store ptr %2, ptr %6, align 8
  %7 = load ptr, ptr @dijkstra_queueHead, align 8
  %8 = icmp ne ptr %7, null
  br i1 %8, label %9, label %27

9:                                                ; preds = %3
  %10 = load ptr, ptr @dijkstra_queueHead, align 8
  %11 = getelementptr inbounds %struct._QITEM, ptr %10, i32 0, i32 0
  %12 = load i32, ptr %11, align 8
  %13 = load ptr, ptr %4, align 8
  store i32 %12, ptr %13, align 4
  %14 = load ptr, ptr @dijkstra_queueHead, align 8
  %15 = getelementptr inbounds %struct._QITEM, ptr %14, i32 0, i32 1
  %16 = load i32, ptr %15, align 4
  %17 = load ptr, ptr %5, align 8
  store i32 %16, ptr %17, align 4
  %18 = load ptr, ptr @dijkstra_queueHead, align 8
  %19 = getelementptr inbounds %struct._QITEM, ptr %18, i32 0, i32 2
  %20 = load i32, ptr %19, align 8
  %21 = load ptr, ptr %6, align 8
  store i32 %20, ptr %21, align 4
  %22 = load ptr, ptr @dijkstra_queueHead, align 8
  %23 = getelementptr inbounds %struct._QITEM, ptr %22, i32 0, i32 3
  %24 = load ptr, ptr %23, align 8
  store ptr %24, ptr @dijkstra_queueHead, align 8
  %25 = load i32, ptr @dijkstra_queueCount, align 4
  %26 = add nsw i32 %25, -1
  store i32 %26, ptr @dijkstra_queueCount, align 4
  br label %27

27:                                               ; preds = %9, %3
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @dijkstra_qcount() #0 {
  %1 = load i32, ptr @dijkstra_queueCount, align 4
  ret i32 %1
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @dijkstra_find(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  store i32 %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  store i32 0, ptr %8, align 4
  store i32 0, ptr %10, align 4
  store i32 0, ptr %6, align 4
  br label %12

12:                                               ; preds = %24, %2
  %13 = load i32, ptr %6, align 4
  %14 = icmp slt i32 %13, 100
  br i1 %14, label %15, label %27

15:                                               ; preds = %12
  %16 = load i32, ptr %6, align 4
  %17 = sext i32 %16 to i64
  %18 = getelementptr inbounds [100 x %struct._NODE], ptr @dijkstra_rgnNodes, i64 0, i64 %17
  %19 = getelementptr inbounds %struct._NODE, ptr %18, i32 0, i32 0
  store i32 9999, ptr %19, align 4
  %20 = load i32, ptr %6, align 4
  %21 = sext i32 %20 to i64
  %22 = getelementptr inbounds [100 x %struct._NODE], ptr @dijkstra_rgnNodes, i64 0, i64 %21
  %23 = getelementptr inbounds %struct._NODE, ptr %22, i32 0, i32 1
  store i32 9999, ptr %23, align 4
  br label %24

24:                                               ; preds = %15
  %25 = load i32, ptr %6, align 4
  %26 = add nsw i32 %25, 1
  store i32 %26, ptr %6, align 4
  br label %12, !llvm.loop !10

27:                                               ; preds = %12
  %28 = load i32, ptr %4, align 4
  %29 = load i32, ptr %5, align 4
  %30 = icmp eq i32 %28, %29
  br i1 %30, label %31, label %32

31:                                               ; preds = %27
  br label %109

32:                                               ; preds = %27
  %33 = load i32, ptr %4, align 4
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds [100 x %struct._NODE], ptr @dijkstra_rgnNodes, i64 0, i64 %34
  %36 = getelementptr inbounds %struct._NODE, ptr %35, i32 0, i32 0
  store i32 0, ptr %36, align 4
  %37 = load i32, ptr %4, align 4
  %38 = sext i32 %37 to i64
  %39 = getelementptr inbounds [100 x %struct._NODE], ptr @dijkstra_rgnNodes, i64 0, i64 %38
  %40 = getelementptr inbounds %struct._NODE, ptr %39, i32 0, i32 1
  store i32 9999, ptr %40, align 4
  %41 = load i32, ptr %4, align 4
  %42 = call i32 @dijkstra_enqueue(i32 noundef %41, i32 noundef 0, i32 noundef 9999)
  %43 = icmp eq i32 %42, -1
  br i1 %43, label %44, label %45

44:                                               ; preds = %32
  store i32 -1, ptr %3, align 4
  br label %110

45:                                               ; preds = %32
  br label %46

46:                                               ; preds = %107, %45
  %47 = call i32 @dijkstra_qcount()
  %48 = icmp sgt i32 %47, 0
  br i1 %48, label %49, label %108

49:                                               ; preds = %46
  call void @dijkstra_dequeue(ptr noundef %8, ptr noundef %10, ptr noundef %7)
  store i32 0, ptr %11, align 4
  br label %50

50:                                               ; preds = %104, %49
  %51 = load i32, ptr %11, align 4
  %52 = icmp slt i32 %51, 100
  br i1 %52, label %53, label %107

53:                                               ; preds = %50
  %54 = load i32, ptr %8, align 4
  %55 = sext i32 %54 to i64
  %56 = getelementptr inbounds [100 x [100 x i8]], ptr @dijkstra_AdjMatrix, i64 0, i64 %55
  %57 = load i32, ptr %11, align 4
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds [100 x i8], ptr %56, i64 0, i64 %58
  %60 = load i8, ptr %59, align 1
  %61 = zext i8 %60 to i32
  store i32 %61, ptr %9, align 4
  %62 = icmp ne i32 %61, 9999
  br i1 %62, label %63, label %103

63:                                               ; preds = %53
  %64 = load i32, ptr %11, align 4
  %65 = sext i32 %64 to i64
  %66 = getelementptr inbounds [100 x %struct._NODE], ptr @dijkstra_rgnNodes, i64 0, i64 %65
  %67 = getelementptr inbounds %struct._NODE, ptr %66, i32 0, i32 0
  %68 = load i32, ptr %67, align 4
  %69 = icmp eq i32 9999, %68
  br i1 %69, label %80, label %70

70:                                               ; preds = %63
  %71 = load i32, ptr %11, align 4
  %72 = sext i32 %71 to i64
  %73 = getelementptr inbounds [100 x %struct._NODE], ptr @dijkstra_rgnNodes, i64 0, i64 %72
  %74 = getelementptr inbounds %struct._NODE, ptr %73, i32 0, i32 0
  %75 = load i32, ptr %74, align 4
  %76 = load i32, ptr %9, align 4
  %77 = load i32, ptr %10, align 4
  %78 = add nsw i32 %76, %77
  %79 = icmp sgt i32 %75, %78
  br i1 %79, label %80, label %102

80:                                               ; preds = %70, %63
  %81 = load i32, ptr %10, align 4
  %82 = load i32, ptr %9, align 4
  %83 = add nsw i32 %81, %82
  %84 = load i32, ptr %11, align 4
  %85 = sext i32 %84 to i64
  %86 = getelementptr inbounds [100 x %struct._NODE], ptr @dijkstra_rgnNodes, i64 0, i64 %85
  %87 = getelementptr inbounds %struct._NODE, ptr %86, i32 0, i32 0
  store i32 %83, ptr %87, align 4
  %88 = load i32, ptr %8, align 4
  %89 = load i32, ptr %11, align 4
  %90 = sext i32 %89 to i64
  %91 = getelementptr inbounds [100 x %struct._NODE], ptr @dijkstra_rgnNodes, i64 0, i64 %90
  %92 = getelementptr inbounds %struct._NODE, ptr %91, i32 0, i32 1
  store i32 %88, ptr %92, align 4
  %93 = load i32, ptr %11, align 4
  %94 = load i32, ptr %10, align 4
  %95 = load i32, ptr %9, align 4
  %96 = add nsw i32 %94, %95
  %97 = load i32, ptr %8, align 4
  %98 = call i32 @dijkstra_enqueue(i32 noundef %93, i32 noundef %96, i32 noundef %97)
  %99 = icmp eq i32 %98, -1
  br i1 %99, label %100, label %101

100:                                              ; preds = %80
  store i32 -1, ptr %3, align 4
  br label %110

101:                                              ; preds = %80
  br label %102

102:                                              ; preds = %101, %70
  br label %103

103:                                              ; preds = %102, %53
  br label %104

104:                                              ; preds = %103
  %105 = load i32, ptr %11, align 4
  %106 = add nsw i32 %105, 1
  store i32 %106, ptr %11, align 4
  br label %50, !llvm.loop !11

107:                                              ; preds = %50
  br label %46, !llvm.loop !12

108:                                              ; preds = %46
  br label %109

109:                                              ; preds = %108, %31
  store i32 0, ptr %3, align 4
  br label %110

110:                                              ; preds = %109, %100, %44
  %111 = load i32, ptr %3, align 4
  ret i32 %111
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @dijkstra_main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i32 50, ptr %2, align 4
  br label %3

3:                                                ; preds = %25, %0
  %4 = load i32, ptr %1, align 4
  %5 = icmp slt i32 %4, 20
  br i1 %5, label %6, label %30

6:                                                ; preds = %3
  %7 = load i32, ptr %2, align 4
  %8 = srem i32 %7, 100
  store i32 %8, ptr %2, align 4
  %9 = load i32, ptr %1, align 4
  %10 = load i32, ptr %2, align 4
  %11 = call i32 @dijkstra_find(i32 noundef %9, i32 noundef %10)
  %12 = icmp eq i32 %11, -1
  br i1 %12, label %13, label %16

13:                                               ; preds = %6
  %14 = load i32, ptr @dijkstra_checksum, align 4
  %15 = add nsw i32 %14, -1
  store i32 %15, ptr @dijkstra_checksum, align 4
  br label %31

16:                                               ; preds = %6
  %17 = load i32, ptr %2, align 4
  %18 = sext i32 %17 to i64
  %19 = getelementptr inbounds [100 x %struct._NODE], ptr @dijkstra_rgnNodes, i64 0, i64 %18
  %20 = getelementptr inbounds %struct._NODE, ptr %19, i32 0, i32 0
  %21 = load i32, ptr %20, align 4
  %22 = load i32, ptr @dijkstra_checksum, align 4
  %23 = add nsw i32 %22, %21
  store i32 %23, ptr @dijkstra_checksum, align 4
  br label %24

24:                                               ; preds = %16
  store i32 0, ptr @dijkstra_queueNext, align 4
  br label %25

25:                                               ; preds = %24
  %26 = load i32, ptr %1, align 4
  %27 = add nsw i32 %26, 1
  store i32 %27, ptr %1, align 4
  %28 = load i32, ptr %2, align 4
  %29 = add nsw i32 %28, 1
  store i32 %29, ptr %2, align 4
  br label %3, !llvm.loop !13

30:                                               ; preds = %3
  br label %31

31:                                               ; preds = %30, %13
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  call void @dijkstra_init()
  call void @dijkstra_main()
  %2 = call i32 @dijkstra_return()
  ret i32 %2
}

attributes #0 = { noinline nounwind uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Ubuntu clang version 18.1.8 (++20240731024944+3b5b5c1ec4a3-1~exp1~20240731145000.144)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
!12 = distinct !{!12, !7}
!13 = distinct !{!13, !7}
