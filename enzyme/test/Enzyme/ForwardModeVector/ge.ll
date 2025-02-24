; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -instsimplify -adce -loop-deletion -correlated-propagation -simplifycfg -early-cse -S | FileCheck %s

%struct.Gradients = type { double, double, double }

; Function Attrs: nounwind
declare %struct.Gradients @__enzyme_fwddiff(i8*, ...)

; void __enzyme_autodiff(void*, ...);

; double cache(double* x, unsigned N) {
;     double sum = 0.0;
;     for(unsigned i=0; i<=N; i++) {
;         sum += x[i] * x[i];
;     }
;     x[0] = 0.0;
;     return sum;
; }

; void ad(double* in, double* din, unsigned N) {
;     __enzyme_autodiff(cache, in, din, N);
; }

; ModuleID = 'foo.c'
; source_filename = "foo.c"
; target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
; target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: norecurse nounwind uwtable
define dso_local double @cache(double* nocapture %x, i32 %N) #0 {
entry:
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  store double 0.000000e+00, double* %x, align 8, !tbaa !2
  ret double %add

for.body:                                         ; preds = %entry, %for.body
  %i.013 = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %sum.012 = phi double [ 0.000000e+00, %entry ], [ %add, %for.body ]
  %idxprom = zext i32 %i.013 to i64
  %arrayidx = getelementptr inbounds double, double* %x, i64 %idxprom
  %0 = load double, double* %arrayidx, align 8, !tbaa !2
  %mul = fmul double %0, %0
  %add = fadd double %sum.012, %mul
  %inc = add i32 %i.013, 1
  %cmp = icmp ugt i32 %inc, %N
  br i1 %cmp, label %for.cond.cleanup, label %for.body
}

; Function Attrs: nounwind uwtable
define dso_local void @ad(double* %in, double* %din1, double* %din2, double* %din3, i32 %N) local_unnamed_addr #1 {
entry:
  tail call %struct.Gradients (i8*, ...) @__enzyme_fwddiff(i8* bitcast (double (double*, i32)* @cache to i8*),  metadata !"enzyme_width", i64 3, double* %in, double* %din1, double* %din2, double* %din3, i32 %N) #3
  ret void
}

attributes #0 = { norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 7.0.0 (trunk 336729)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"double", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}

; CHECK: define {{[^@]+}}@fwddiffe3cache(double* nocapture [[X:%.*]], [3 x double*] %"x'", i32 [[N:%.*]]) 
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    store double 0.000000e+00, double* [[X]], align 8, !tbaa !2
; CHECK-NEXT:    store double 0.000000e+00, double* [[TMP2:%.*]], align 8
; CHECK-NEXT:    store double 0.000000e+00, double* [[TMP3:%.*]], align 8
; CHECK-NEXT:    store double 0.000000e+00, double* [[TMP4:%.*]], align 8
; CHECK-NEXT:    ret [3 x double] [[TMP20:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[TMP0:%.*]] = phi {{(fast )?}}[3 x double] [ zeroinitializer, [[ENTRY:%.*]] ], [ [[TMP20]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[FOR_BODY]] ], [ 0, [[ENTRY]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i64 [[IV]] to i32
; CHECK-NEXT:    [[IDXPROM:%.*]] = zext i32 [[TMP1]] to i64
; CHECK-NEXT:    [[TMP2]] = extractvalue [3 x double*] %"x'", 0
; CHECK-NEXT:    %"arrayidx'ipg" = getelementptr inbounds double, double* [[TMP2]], i64 [[IDXPROM]]
; CHECK-NEXT:    [[TMP3]] = extractvalue [3 x double*] %"x'", 1
; CHECK-NEXT:    %"arrayidx'ipg1" = getelementptr inbounds double, double* [[TMP3]], i64 [[IDXPROM]]
; CHECK-NEXT:    [[TMP4]] = extractvalue [3 x double*] %"x'", 2
; CHECK-NEXT:    %"arrayidx'ipg2" = getelementptr inbounds double, double* [[TMP4]], i64 [[IDXPROM]]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds double, double* [[X]], i64 [[IDXPROM]]
; CHECK-NEXT:    %"'ipl" = load double, double* %"arrayidx'ipg", align 8, !tbaa !2
; CHECK-NEXT:    %"'ipl3" = load double, double* %"arrayidx'ipg1", align 8, !tbaa !2
; CHECK-NEXT:    %"'ipl4" = load double, double* %"arrayidx'ipg2", align 8, !tbaa !2
; CHECK-NEXT:    [[TMP5:%.*]] = load double, double* [[ARRAYIDX]], align 8, !tbaa !2
; CHECK-NEXT:    [[TMP6:%.*]] = fmul fast double %"'ipl", [[TMP5]]
; CHECK-NEXT:    [[TMP7:%.*]] = fadd fast double [[TMP6]], [[TMP6]]
; CHECK-NEXT:    [[TMP8:%.*]] = fmul fast double %"'ipl3", [[TMP5]]
; CHECK-NEXT:    [[TMP9:%.*]] = fadd fast double [[TMP8]], [[TMP8]]
; CHECK-NEXT:    [[TMP10:%.*]] = fmul fast double %"'ipl4", [[TMP5]]
; CHECK-NEXT:    [[TMP11:%.*]] = fadd fast double [[TMP10]], [[TMP10]]
; CHECK-NEXT:    [[TMP12:%.*]] = extractvalue [3 x double] [[TMP0]], 0
; CHECK-NEXT:    [[TMP13:%.*]] = fadd fast double [[TMP12]], [[TMP7]]
; CHECK-NEXT:    [[TMP14:%.*]] = insertvalue [3 x double] undef, double [[TMP13]], 0
; CHECK-NEXT:    [[TMP15:%.*]] = extractvalue [3 x double] [[TMP0]], 1
; CHECK-NEXT:    [[TMP16:%.*]] = fadd fast double [[TMP15]], [[TMP9]]
; CHECK-NEXT:    [[TMP17:%.*]] = insertvalue [3 x double] [[TMP14]], double [[TMP16]], 1
; CHECK-NEXT:    [[TMP18:%.*]] = extractvalue [3 x double] [[TMP0]], 2
; CHECK-NEXT:    [[TMP19:%.*]] = fadd fast double [[TMP18]], [[TMP11]]
; CHECK-NEXT:    [[TMP20]] = insertvalue [3 x double] [[TMP17]], double [[TMP19]], 2
; CHECK-NEXT:    [[INC:%.*]] = add i32 [[TMP1]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32 [[INC]], [[N]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_COND_CLEANUP:%.*]], label [[FOR_BODY]]
;
