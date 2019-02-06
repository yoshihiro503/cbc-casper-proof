theory CodeGeneration

imports Main CBCCasper SafetyOracle TFGCasper

begin

code_printing
  type_constructor bool => (Haskell) "bool"
  | constant True => (Haskell) "true"
  | constant False => (Haskell) "false"

(* FIXME: How can we remove member func? *)
definition member :: "'a list \<Rightarrow> 'a \<Rightarrow> bool"
  where
    [code_abbrev]: "member xs x \<longleftrightarrow> x \<in> set xs"

instantiation consensus_value :: equal
begin 

definition "HOL.equal (x ::consensus_value) y \<longleftrightarrow> x = y"
instance  by standard (simp add: equal_consensus_value_def)

end

code_printing
  class_instance consensus_value :: "HOL.equal" => (Haskell) -
  (* |type_constructor consensus_value => (Haskell) "Map String String" *)


instantiation validator :: equal
begin 

definition "HOL.equal (x ::validator) y \<longleftrightarrow> x = y"
instance  by standard (simp add: equal_validator_def)

end

code_printing
  class_instance validator :: "HOL.equal" => (Haskell) -
  (* | type_constructor validator => (Haskell) "Map String String" *)

interpretation p: Params V W t C \<epsilon> for V W t C \<epsilon>
  done

(* Define a constant *)
definition "is_clique_oracle = p.is_clique_oracle"

export_code is_clique is_clique_oracle in Haskell
  module_name SafetyOracle file GeneratedCode


interpretation gp: GhostParams V W t C \<epsilon> genesis B prev for V W t C \<epsilon> genesis B prev 
  done

(* FIXME: Wellsortedness error *)
(* 
definition "best_children = gp.best_children"
export_code best_children in Haskell
  module_name TFGCasper file GeneratedCode
*)

(* FIXME: No code equations for GhostParams.GHOST *)
(*
definition "estimator = gp.estimator"
export_code estimator in Haskell
  module_name TFGCasper file GeneratedCode
*)

end