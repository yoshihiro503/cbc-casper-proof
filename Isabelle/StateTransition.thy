theory StateTransition

imports Main CBCCasper MessageJustification

begin

(* ###################################################### *)
(* State transition *)
(* ###################################################### *)

definition (in Params) state_transition :: "state rel"
  where 
    "state_transition = {(\<sigma>1, \<sigma>2). {\<sigma>1, \<sigma>2} \<subseteq> \<Sigma> \<and> is_future_state(\<sigma>1, \<sigma>2)}" 

lemma (in Params) reflexivity_of_state_transition :
  "refl_on \<Sigma> state_transition"  
  apply (simp add: state_transition_def refl_on_def)
  by auto

lemma (in Params) transitivity_of_state_transition :
  "trans state_transition"  
  apply (simp add: state_transition_def trans_def)
  by auto

lemma (in Params) state_transition_is_preorder :
  "preorder_on \<Sigma> state_transition"
  by (simp add: preorder_on_def reflexivity_of_state_transition transitivity_of_state_transition)

lemma (in Params) antisymmetry_of_state_transition :
  "antisym state_transition"  
  apply (simp add: state_transition_def antisym_def)
  by auto

lemma (in Params) state_transition_is_partial_order :
  "partial_order_on \<Sigma> state_transition"
  by (simp add: partial_order_on_def state_transition_is_preorder antisymmetry_of_state_transition)

(* Definition 7.17 *)
definition (in Protocol) minimal_transitions :: "(state * state) set"
  where
    "minimal_transitions \<equiv> {(\<sigma>, \<sigma>') | \<sigma> \<sigma>'. \<sigma> \<in> \<Sigma>t \<and> \<sigma>' \<in> \<Sigma>t \<and> is_future_state (\<sigma>, \<sigma>') \<and> \<sigma> \<noteq> \<sigma>'
      \<and> (\<nexists> \<sigma>''. \<sigma>'' \<in> \<Sigma> \<and> is_future_state (\<sigma>, \<sigma>'') \<and> is_future_state (\<sigma>'', \<sigma>') \<and> \<sigma> \<noteq> \<sigma>'' \<and> \<sigma>'' \<noteq> \<sigma>')}"

(* A minimal transition corresponds to receiving a single new message with justification drawn from the initial
protocol state *)
definition immediately_next_message where
  "immediately_next_message = (\<lambda>(\<sigma>, m). justification m \<subseteq> \<sigma> \<and> m \<notin> \<sigma>)"

lemma (in Protocol) state_transition_by_immediately_next_message_of_same_depth_non_zero: 
  "\<forall>n\<ge>1. \<forall>\<sigma>\<in>\<Sigma>i (V,C,\<epsilon>) n. \<forall>m\<in>Mi (V,C,\<epsilon>) n. immediately_next_message (\<sigma>,m) \<longrightarrow> \<sigma> \<union> {m} \<in> \<Sigma>i (V,C,\<epsilon>) (n+1)"
  apply (rule, rule, rule, rule, rule)
proof-
  fix n \<sigma> m
  assume "1 \<le> n" "\<sigma> \<in> \<Sigma>i (V, C, \<epsilon>) n" "m \<in> Mi (V, C, \<epsilon>) n" "immediately_next_message (\<sigma>, m)"

  have "\<exists>n'. n = Suc n'"
    using \<open>1 \<le> n\<close> old.nat.exhaust by auto
  hence si: "\<Sigma>i (V,C,\<epsilon>) n = {\<sigma> \<in> Pow (Mi (V,C,\<epsilon>) (n - 1)). finite \<sigma> \<and> (\<forall> m. m \<in> \<sigma> \<longrightarrow> justification m \<subseteq> \<sigma>)}"
    by force

  hence "\<Sigma>i (V,C,\<epsilon>) (n+1) = {\<sigma> \<in> Pow (Mi (V,C,\<epsilon>) n). finite \<sigma> \<and> (\<forall> m. m \<in> \<sigma> \<longrightarrow> justification m \<subseteq> \<sigma>)}"
    by force

  have "justification m \<subseteq> \<sigma>"
    using immediately_next_message_def
    by (metis (no_types, lifting) \<open>immediately_next_message (\<sigma>, m)\<close> case_prod_conv)
  hence "justification m \<subseteq> \<sigma> \<union> {m}"
    by blast
  moreover have "\<And>m'. finite \<sigma> \<and> m' \<in> \<sigma> \<Longrightarrow> justification m' \<subseteq> \<sigma>"
    using \<open>\<sigma> \<in> \<Sigma>i (V, C, \<epsilon>) n\<close> si by blast
  hence"\<And>m'. finite \<sigma> \<and> m' \<in> \<sigma> \<Longrightarrow> justification m' \<subseteq> \<sigma> \<union> {m}"
    by auto
  ultimately have "\<And>m'. m' \<in> \<sigma> \<union> {m} \<Longrightarrow> justification m \<subseteq> \<sigma>"
    using \<open>justification m \<subseteq> \<sigma>\<close> by blast

  have "{m} \<in> Pow (Mi (V,C,\<epsilon>) n)"
    using \<open>m \<in> Mi (V, C, \<epsilon>) n\<close> by auto
  moreover have "\<sigma> \<in> Pow (Mi (V,C,\<epsilon>) (n-1))"
    using \<open>\<sigma> \<in> \<Sigma>i (V, C, \<epsilon>) n\<close> si by auto
  hence "\<sigma> \<in> Pow (Mi (V,C,\<epsilon>) n)"
    using Mi_monotonic
    by (metis (full_types) PowD PowI Suc_eq_plus1 \<open>\<exists>n'. n = Suc n'\<close> diff_Suc_1 subset_iff)
  ultimately have "\<sigma> \<union> {m} \<in> Pow (Mi (V,C,\<epsilon>) n)"
    by blast

  show "\<sigma> \<union> {m} \<in> \<Sigma>i (V, C, \<epsilon>) (n + 1)"
    using \<open>\<And>m'. finite \<sigma> \<and> m' \<in> \<sigma> \<Longrightarrow> justification m' \<subseteq> \<sigma> \<union> {m}\<close> \<open>\<sigma> \<union> {m} \<in> Pow (Mi (V, C, \<epsilon>) n)\<close> \<open>justification m \<subseteq> \<sigma> \<union> {m}\<close> 
    \<open>\<sigma> \<in> \<Sigma>i (V, C, \<epsilon>) n\<close> si by auto
qed

lemma (in Protocol) state_transition_by_immediately_next_message_of_same_depth: 
  "\<forall>\<sigma>\<in>\<Sigma>i (V,C,\<epsilon>) n. \<forall>m\<in>Mi (V,C,\<epsilon>) n. immediately_next_message (\<sigma>,m) \<longrightarrow> \<sigma> \<union> {m} \<in> \<Sigma>i (V,C,\<epsilon>) (n+1)"
  apply (cases n)
  apply auto[1]
  using state_transition_by_immediately_next_message_of_same_depth_non_zero
  by (metis le_add1 plus_1_eq_Suc)

lemma (in Params) past_state_exists_in_same_depth :
  "\<forall> \<sigma> \<sigma>'. \<sigma>' \<in> \<Sigma>i (V,C,\<epsilon>) n \<longrightarrow> \<sigma> \<subseteq> \<sigma>' \<longrightarrow> \<sigma> \<in> \<Sigma> \<longrightarrow> \<sigma> \<in> \<Sigma>i (V,C,\<epsilon>) n"
  apply (rule, rule, rule, rule, rule) 
proof (cases n)
  case 0
  show "\<And>\<sigma> \<sigma>'. \<sigma>' \<in> \<Sigma>i (V, C, \<epsilon>) n \<Longrightarrow> \<sigma> \<subseteq> \<sigma>' \<Longrightarrow> \<sigma> \<in> \<Sigma> \<Longrightarrow> n = 0 \<Longrightarrow> \<sigma> \<in> \<Sigma>i (V, C, \<epsilon>) n"
    by auto
next
  case (Suc nat)
  show "\<And>\<sigma> \<sigma>' nat. \<sigma>' \<in> \<Sigma>i (V, C, \<epsilon>) n \<Longrightarrow> \<sigma> \<subseteq> \<sigma>' \<Longrightarrow> \<sigma> \<in> \<Sigma> \<Longrightarrow> n = Suc nat \<Longrightarrow> \<sigma> \<in> \<Sigma>i (V, C, \<epsilon>) n"
  proof -
  fix \<sigma> \<sigma>'
  assume "\<sigma>' \<in> \<Sigma>i (V, C, \<epsilon>) n"
  and "\<sigma> \<subseteq> \<sigma>'" 
  and "\<sigma> \<in> \<Sigma>"
  have "n > 0"
    by (simp add: Suc)
  have "finite \<sigma> \<and> (\<forall> m. m \<in> \<sigma> \<longrightarrow> justification m \<subseteq> \<sigma>)"
    using \<open>\<sigma> \<in> \<Sigma>\<close> state_is_finite state_is_in_pow_Mi by blast
  moreover have "\<sigma> \<in> Pow (Mi (V, C, \<epsilon>) (n - 1))"
    using \<open>\<sigma> \<subseteq> \<sigma>'\<close>
    by (smt Pow_iff Suc_eq_plus1 \<Sigma>i_monotonic \<Sigma>i_subset_Mi \<open>\<sigma>' \<in> \<Sigma>i (V, C, \<epsilon>) n\<close> add_diff_cancel_left' add_eq_if diff_is_0_eq diff_le_self plus_1_eq_Suc subset_iff)
  ultimately have  "\<sigma> \<in> {\<sigma> \<in> Pow (Mi (V,C,\<epsilon>) (n - 1)). finite \<sigma> \<and> (\<forall> m. m \<in> \<sigma> \<longrightarrow> justification m \<subseteq> \<sigma>)}"
    by blast
  then show "\<sigma> \<in> \<Sigma>i (V, C, \<epsilon>) n"
    by (simp add: Suc)
  qed
qed

lemma (in Protocol) immediately_next_message_exists_in_same_depth: 
  "\<forall> \<sigma> \<in> \<Sigma>. \<forall> m \<in> M. immediately_next_message (\<sigma>,m) \<longrightarrow> (\<exists> n \<in> \<nat>. \<sigma> \<in> \<Sigma>i (V,C,\<epsilon>) n \<and> m \<in> Mi (V,C,\<epsilon>) n)"
  apply (simp add: immediately_next_message_def M_def \<Sigma>_def)
  using past_state_exists_in_same_depth
  using \<Sigma>i_is_subset_of_\<Sigma> by blast

lemma (in Protocol) state_transition_by_immediately_next_message: 
  "\<forall> \<sigma> \<in>\<Sigma>. \<forall> m \<in> M. immediately_next_message (\<sigma>,m) \<longrightarrow> \<sigma> \<union> {m} \<in> \<Sigma>"
  apply (rule, rule, rule)
proof - 
  fix \<sigma> m
  assume "\<sigma> \<in> \<Sigma>" 
  and "m \<in> M" 
  and "immediately_next_message (\<sigma>, m)" 
  then have "(\<exists> n \<in> \<nat>. \<sigma> \<in> \<Sigma>i (V,C,\<epsilon>) n \<and> m \<in> Mi (V,C,\<epsilon>) n)"
    using immediately_next_message_exists_in_same_depth \<open>\<sigma> \<in> \<Sigma>\<close> \<open>m \<in> M\<close>
    by blast
  then have "\<exists> n \<in> \<nat>. \<sigma> \<union> {m} \<in> \<Sigma>i (V,C,\<epsilon>) (n + 1)"
    using state_transition_by_immediately_next_message_of_same_depth
    using \<open>immediately_next_message (\<sigma>, m)\<close> by blast
  show "\<sigma> \<union> {m} \<in> \<Sigma>"
    apply (simp add: \<Sigma>_def)
    by (metis Nats_1 Nats_add Un_insert_right \<open>\<exists>n\<in>\<nat>. \<sigma> \<union> {m} \<in> \<Sigma>i (V, C, \<epsilon>) (n + 1)\<close> sup_bot.right_neutral)
qed

lemma (in Protocol) state_transition_imps_immediately_next_message: 
  "\<forall> \<sigma> \<in>\<Sigma>. \<forall> m \<in> M. \<sigma> \<union> {m} \<in> \<Sigma> \<and> m \<notin> \<sigma> \<longrightarrow> immediately_next_message (\<sigma>,m)"
proof - 
  have "\<forall> \<sigma> \<in>\<Sigma>. \<forall> m \<in> M. \<sigma> \<union> {m} \<in> \<Sigma> \<longrightarrow> (\<forall> m' \<in> \<sigma> \<union> {m}. justification m' \<subseteq> \<sigma> \<union> {m})"
    using state_is_in_pow_Mi by blast
  then have "\<forall> \<sigma> \<in>\<Sigma>. \<forall> m \<in> M. \<sigma> \<union> {m} \<in> \<Sigma> \<longrightarrow> justification m \<subseteq> \<sigma> \<union> {m}"
    by auto
  then have "\<forall> \<sigma> \<in>\<Sigma>. \<forall> m \<in> M. \<sigma> \<union> {m} \<in> \<Sigma> \<and> m \<notin> \<sigma> \<longrightarrow> justification m \<subseteq> \<sigma>"
    using justification_implies_different_messages justified_def by fastforce
  then show ?thesis
    by (simp add: immediately_next_message_def)
qed

lemma (in Protocol) state_transition_only_made_by_immediately_next_message: 
  "\<forall> \<sigma> \<in> \<Sigma>. \<forall> m \<in> M. \<sigma> \<union> {m} \<in> \<Sigma> \<and> m \<notin> \<sigma> \<longleftrightarrow> immediately_next_message (\<sigma>, m)"
  using state_transition_imps_immediately_next_message state_transition_by_immediately_next_message
  apply (simp add: immediately_next_message_def)
  by blast

lemma (in Protocol) state_transition_is_immediately_next_message: 
  "\<forall> \<sigma> \<in> \<Sigma>. \<forall> m \<in> M. \<sigma> \<union> {m} \<in> \<Sigma>  \<longleftrightarrow> justification m \<subseteq> \<sigma>"
  using state_transition_only_made_by_immediately_next_message 
  apply (simp add: immediately_next_message_def) 
  using insert_Diff state_is_in_pow_Mi by fastforce

(* NJH19 Lemma 8 *)
lemma (in Protocol) strict_subset_of_state_have_immediately_next_messages: 
  "\<forall> \<sigma> \<in> \<Sigma>. \<forall> \<sigma>'. \<sigma>' \<subset> \<sigma> \<longrightarrow> (\<exists> m \<in> \<sigma> - \<sigma>'. immediately_next_message (\<sigma>', m))"
  apply (simp add: immediately_next_message_def)
  apply (rule, rule, rule)
proof -
  fix \<sigma> \<sigma>'
  assume "\<sigma> \<in> \<Sigma>"
  assume "\<sigma>' \<subset> \<sigma>"
  show "\<exists> m \<in> \<sigma> - \<sigma>'. justification m \<subseteq> \<sigma>'"
  proof (rule ccontr)
    assume "\<not> (\<exists> m \<in> \<sigma> - \<sigma>'. justification m \<subseteq> \<sigma>')"
    then have "\<forall> m \<in> \<sigma> - \<sigma>'. \<exists> m' \<in> justification m. m' \<in> \<sigma> - \<sigma>'"
      using \<open>\<not> (\<exists>m\<in>\<sigma> - \<sigma>'. justification m \<subseteq> \<sigma>')\<close> state_is_in_pow_Mi \<open>\<sigma>' \<subset> \<sigma>\<close>
      by (metis Diff_iff \<open>\<sigma> \<in> \<Sigma>\<close> subset_eq)
    then have "\<forall> m \<in> \<sigma> - \<sigma>'. \<exists> m'. justified m' m \<and> m' \<in> \<sigma> - \<sigma>'"
      using justified_def by auto 
    then have "\<forall> m \<in> \<sigma> - \<sigma>'. \<exists> m'. justified m' m \<and> m' \<in> \<sigma> - \<sigma>' \<and> m \<noteq> m'" 
      using justification_implies_different_messages  state_difference_is_valid_message
      message_in_state_is_valid  \<open>\<sigma>' \<subset> \<sigma>\<close>
      by (meson DiffD1 \<open>\<sigma> \<in> \<Sigma>\<close>)
    have "\<sigma> - \<sigma>' \<subseteq> M"
      using \<open>\<sigma> \<in> \<Sigma>\<close> \<open>\<sigma>' \<subset> \<sigma>\<close> state_is_subset_of_M by auto
    then have "\<exists> m_min \<in> \<sigma> - \<sigma>'. \<forall> m. justified m m_min \<longrightarrow> m \<notin> \<sigma> - \<sigma>'"
      using subset_of_M_have_minimal_of_justification \<open>\<sigma>' \<subset> \<sigma>\<close>
      by blast
    then show False
      using \<open>\<forall> m \<in> \<sigma> - \<sigma>'. \<exists> m'. justified m' m \<and> m' \<in> \<sigma> - \<sigma>'\<close> by blast
  qed
qed

lemma (in Protocol) union_of_two_states_is_state :
  "\<forall> \<sigma>1 \<in> \<Sigma>. \<forall> \<sigma>2 \<in> \<Sigma>. (\<sigma>1 \<union> \<sigma>2) \<in> \<Sigma>"
  apply (rule, rule)
proof - 
  fix \<sigma>1 \<sigma>2
  assume "\<sigma>1 \<in> \<Sigma>" and "\<sigma>2 \<in> \<Sigma>"
  show "\<sigma>1 \<union> \<sigma>2 \<in> \<Sigma>"
  proof (cases "\<sigma>1 \<subseteq> \<sigma>2")
    case True
    then show ?thesis
      by (simp add: Un_absorb1 \<open>\<sigma>2 \<in> \<Sigma>\<close>)
  next
    case False
    then have "\<not> \<sigma>1 \<subseteq> \<sigma>2" by simp
    have "\<forall> \<sigma> \<in> \<Sigma>. \<forall> \<sigma>' \<in> \<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<longrightarrow> (\<exists> m \<in> \<sigma> - (\<sigma> \<inter> \<sigma>'). immediately_next_message(\<sigma> \<inter> \<sigma>', m))"
      by (metis Int_subset_iff psubsetI strict_subset_of_state_have_immediately_next_messages subsetI)  
    then have "\<forall> \<sigma> \<in> \<Sigma>. \<forall> \<sigma>' \<in> \<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<longrightarrow> (\<exists> m \<in> \<sigma> - (\<sigma> \<inter> \<sigma>'). immediately_next_message(\<sigma>', m))"
      apply (simp add: immediately_next_message_def)
      by blast  
    then have "\<forall> \<sigma> \<in> \<Sigma>. \<forall> \<sigma>' \<in> \<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<longrightarrow> (\<exists> m \<in> \<sigma> - \<sigma>'. \<sigma>' \<union> {m} \<in> \<Sigma>)"
      using state_transition_by_immediately_next_message
      by (metis DiffD1 DiffD2 DiffI IntI message_in_state_is_valid)      
    have "\<forall> \<sigma> \<in> \<Sigma>. \<forall> \<sigma>' \<in> \<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<longrightarrow>  \<sigma> \<union> \<sigma>' \<in> \<Sigma>"
    proof - 
      have "\<forall> \<sigma> \<in> \<Sigma>. \<forall> \<sigma>' \<in> \<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<longrightarrow> card (\<sigma> - \<sigma>') > 0"
        by (meson Diff_eq_empty_iff card_0_eq finite_Diff gr0I state_is_finite)
      have "\<forall> n. \<forall> \<sigma> \<in> \<Sigma>. \<forall> \<sigma>' \<in> \<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc n = card (\<sigma> - \<sigma>')\<longrightarrow>  \<sigma> \<union> \<sigma>' \<in> \<Sigma>"
        apply (rule)
      proof - 
        fix n
        show "\<forall>\<sigma>\<in>\<Sigma>. \<forall>\<sigma>'\<in>\<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc n = card (\<sigma> - \<sigma>') \<longrightarrow> \<sigma> \<union> \<sigma>' \<in> \<Sigma>"
          apply (induction n)
          apply (rule, rule, rule)
        proof - 
          fix \<sigma> \<sigma>'
          assume "\<sigma> \<in> \<Sigma>" and "\<sigma>' \<in> \<Sigma>" and "\<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc 0 = card (\<sigma> - \<sigma>')" 
          then have "is_singleton (\<sigma> - \<sigma>')"
            by (simp add: is_singleton_altdef)
          then have "{the_elem (\<sigma> - \<sigma>')} \<union> \<sigma>' \<in> \<Sigma>"
            using \<open>\<forall> \<sigma> \<in> \<Sigma>. \<forall> \<sigma>' \<in> \<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<longrightarrow> (\<exists> m \<in> \<sigma> - \<sigma>'. \<sigma>' \<union> {m} \<in> \<Sigma>)\<close> \<open>\<sigma> \<in> \<Sigma>\<close> \<open>\<sigma>' \<in> \<Sigma>\<close>
            by (metis Un_commute \<open>\<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc 0 = card (\<sigma> - \<sigma>')\<close> is_singleton_the_elem singletonD)
          then show "\<sigma> \<union> \<sigma>' \<in> \<Sigma>"
            by (metis Un_Diff_cancel2 \<open>is_singleton (\<sigma> - \<sigma>')\<close> is_singleton_the_elem)   
        next 
          show "\<And>n. \<forall>\<sigma>\<in>\<Sigma>. \<forall>\<sigma>'\<in>\<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc n = card (\<sigma> - \<sigma>') \<longrightarrow> \<sigma> \<union> \<sigma>' \<in> \<Sigma> \<Longrightarrow> \<forall>\<sigma>\<in>\<Sigma>. \<forall>\<sigma>'\<in>\<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc (Suc n) = card (\<sigma> - \<sigma>') \<longrightarrow> \<sigma> \<union> \<sigma>' \<in> \<Sigma>"
            apply (rule, rule, rule)
          proof -
            fix n \<sigma> \<sigma>'
            assume "\<forall>\<sigma>\<in>\<Sigma>. \<forall>\<sigma>'\<in>\<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc n = card (\<sigma> - \<sigma>') \<longrightarrow> \<sigma> \<union> \<sigma>' \<in> \<Sigma>" and "\<sigma> \<in> \<Sigma>" and "\<sigma>' \<in> \<Sigma>" and "\<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc (Suc n) = card (\<sigma> - \<sigma>')" 
            have "\<forall> m \<in> \<sigma> - \<sigma>'. \<not> \<sigma> \<subseteq> \<sigma>' \<union> {m} \<and> Suc n = card (\<sigma> - (\<sigma>' \<union> {m}))"
              using \<open>\<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc (Suc n) = card (\<sigma> - \<sigma>')\<close> 
              by (metis Diff_eq_empty_iff Diff_insert Un_insert_right \<open>\<sigma> \<in> \<Sigma>\<close> add_diff_cancel_left' card_0_eq card_Suc_Diff1 finite_Diff nat.simps(3) plus_1_eq_Suc state_is_finite sup_bot.right_neutral)
            have "\<exists> m \<in> \<sigma> - \<sigma>'. \<sigma>' \<union> {m} \<in> \<Sigma>"
              using \<open>\<forall> \<sigma> \<in> \<Sigma>. \<forall> \<sigma>' \<in> \<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<longrightarrow> (\<exists> m \<in> \<sigma> - \<sigma>'. \<sigma>' \<union> {m} \<in> \<Sigma>)\<close> \<open>\<sigma> \<in> \<Sigma>\<close> \<open>\<sigma>' \<in> \<Sigma>\<close> \<open>\<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc (Suc n) = card (\<sigma> - \<sigma>')\<close>
              by blast
            then have "\<exists> m \<in> \<sigma> - \<sigma>'. \<sigma>' \<union> {m} \<in> \<Sigma> \<and> \<not> \<sigma> \<subseteq> \<sigma>' \<union> {m} \<and> Suc n = card (\<sigma> - (\<sigma>' \<union> {m}))"
              using \<open>\<forall> m \<in> \<sigma> - \<sigma>'. \<not> \<sigma> \<subseteq> \<sigma>' \<union> {m} \<and> Suc n = card (\<sigma> - (\<sigma>' \<union> {m}))\<close> 
              by simp
            then show "\<sigma> \<union> \<sigma>' \<in> \<Sigma>"
              using \<open>\<forall>\<sigma>\<in>\<Sigma>. \<forall>\<sigma>'\<in>\<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<and> Suc n = card (\<sigma> - \<sigma>') \<longrightarrow> \<sigma> \<union> \<sigma>' \<in> \<Sigma>\<close>
              by (smt Un_Diff_cancel Un_commute Un_insert_right  \<open>\<sigma> \<in> \<Sigma>\<close> insert_absorb2 mk_disjoint_insert sup_bot.right_neutral)
          qed
        qed
      qed
      then show ?thesis
        by (meson \<open>\<forall>\<sigma>\<in>\<Sigma>. \<forall>\<sigma>'\<in>\<Sigma>. \<not> \<sigma> \<subseteq> \<sigma>' \<longrightarrow> (\<exists>m\<in>\<sigma> - \<sigma>'. \<sigma>' \<union> {m} \<in> \<Sigma>)\<close> card_Suc_Diff1 finite_Diff state_is_finite)
    qed
    then show ?thesis
      using False \<open>\<sigma>1 \<in> \<Sigma>\<close> \<open>\<sigma>2 \<in> \<Sigma>\<close> by blast
  qed
qed


lemma (in Protocol) union_of_finite_set_of_states_is_state :
  "\<forall> \<sigma>_set \<subseteq> \<Sigma>. finite \<sigma>_set \<longrightarrow> \<Union> \<sigma>_set \<in> \<Sigma>"
  apply auto
proof -
  have "\<forall> n. \<forall> \<sigma>_set \<subseteq> \<Sigma>. n = card \<sigma>_set \<longrightarrow> finite \<sigma>_set \<longrightarrow> \<Union> \<sigma>_set \<in> \<Sigma>"
    apply (rule)
  proof -
    fix n
    show "\<forall>\<sigma>_set\<subseteq>\<Sigma>. n = card \<sigma>_set \<longrightarrow> finite \<sigma>_set \<longrightarrow> \<Union>\<sigma>_set \<in> \<Sigma>"
      apply (induction n)
      apply (rule, rule, rule, rule)
       apply (simp add: empty_set_exists_in_\<Sigma>)
      apply (rule, rule, rule, rule)
    proof - 
      fix n \<sigma>_set
      assume "\<forall>\<sigma>_set\<subseteq>\<Sigma>. n = card \<sigma>_set \<longrightarrow> finite \<sigma>_set \<longrightarrow> \<Union>\<sigma>_set \<in> \<Sigma>" and "\<sigma>_set \<subseteq> \<Sigma>" and "Suc n = card \<sigma>_set" and "finite \<sigma>_set" 
      then have "\<forall> \<sigma> \<in> \<sigma>_set. \<sigma>_set - {\<sigma>} \<subseteq> \<Sigma> \<and> \<Union> (\<sigma>_set - {\<sigma>}) \<in> \<Sigma>"
        using \<open>\<sigma>_set \<subseteq> \<Sigma>\<close> \<open>Suc n = card \<sigma>_set\<close> \<open>\<forall>\<sigma>_set\<subseteq>\<Sigma>. n = card \<sigma>_set \<longrightarrow> finite \<sigma>_set \<longrightarrow> \<Union>\<sigma>_set \<in> \<Sigma>\<close>
        by (metis (mono_tags, lifting) Suc_inject card.remove finite_Diff insert_Diff insert_subset)  
      then have "\<forall> \<sigma> \<in> \<sigma>_set. \<sigma>_set - {\<sigma>} \<subseteq> \<Sigma> \<and> \<Union> (\<sigma>_set - {\<sigma>}) \<in> \<Sigma> \<and> \<Union> (\<sigma>_set - {\<sigma>}) \<union> \<sigma> \<in> \<Sigma>"
        using union_of_two_states_is_state \<open>\<sigma>_set \<subseteq> \<Sigma>\<close> by auto
      then show "\<Union>\<sigma>_set \<in> \<Sigma>"
        by (metis Sup_bot_conv(1) Sup_insert Un_commute empty_set_exists_in_\<Sigma> insert_Diff)
    qed
  qed
  then show " \<And>\<sigma>_set. \<sigma>_set \<subseteq> \<Sigma> \<Longrightarrow> finite \<sigma>_set \<Longrightarrow> \<Union>\<sigma>_set \<in> \<Sigma>"
    by blast
qed


lemma (in Protocol) state_differences_have_immediately_next_messages: 
  "\<forall> \<sigma> \<in> \<Sigma>. \<forall> \<sigma>'\<in> \<Sigma>. is_future_state (\<sigma>, \<sigma>') \<and> \<sigma> \<noteq> \<sigma>' \<longrightarrow> (\<exists> m \<in> \<sigma>'-\<sigma>. immediately_next_message (\<sigma>, m))"
  using strict_subset_of_state_have_immediately_next_messages
  by (simp add: psubsetI)

lemma non_empty_non_singleton_imps_two_elements : 
  "A \<noteq> \<emptyset> \<Longrightarrow> \<not> is_singleton A \<Longrightarrow> \<exists> a1 a2. a1 \<noteq> a2 \<and> {a1, a2} \<subseteq> A"
  by (metis inf.orderI inf_bot_left insert_subset is_singletonI')

(* A minimal transition corresponds to receiving a single new message with justification drawn from the initial
protocol state *)
lemma (in Protocol) minimal_transition_implies_recieving_single_message :
  "\<forall> \<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions  \<longrightarrow> is_singleton (\<sigma>'- \<sigma>)"
proof (rule ccontr)
  assume "\<not> (\<forall> \<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions \<longrightarrow> is_singleton (\<sigma>'- \<sigma>))"
  then have  "\<exists> \<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions \<and> \<not>  is_singleton (\<sigma>'- \<sigma>)"
    by blast
  have "\<forall> \<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions \<longrightarrow>
              (\<nexists> \<sigma>''. \<sigma>'' \<in> \<Sigma> \<and> is_future_state (\<sigma>, \<sigma>'') \<and> is_future_state (\<sigma>'', \<sigma>') \<and> \<sigma> \<noteq> \<sigma>'' \<and> \<sigma>'' \<noteq> \<sigma>')"
    by (simp add: minimal_transitions_def)
  have "\<forall> \<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions \<and> \<not> is_singleton (\<sigma>'- \<sigma>)
    \<longrightarrow> (\<exists> m1 m2. {m1, m2} \<subseteq> M \<and> m1 \<in> \<sigma>'- \<sigma> \<and> m2 \<in> \<sigma>'- \<sigma> \<and> m1 \<noteq> m2 \<and> immediately_next_message (\<sigma>, m1))"
    apply (rule, rule, rule)
  proof -
    fix \<sigma> \<sigma>'
    assume "(\<sigma>, \<sigma>') \<in> minimal_transitions \<and> \<not> is_singleton (\<sigma>' - \<sigma>)"
    then have "\<sigma>' - \<sigma> \<noteq> \<emptyset>"
      apply (simp add: minimal_transitions_def)
      by blast
    have "\<sigma>' \<in> \<Sigma> \<and> \<sigma> \<in> \<Sigma> \<and> is_future_state (\<sigma>, \<sigma>')"
      using \<open>(\<sigma>, \<sigma>') \<in> minimal_transitions \<and> \<not> is_singleton (\<sigma>' - \<sigma>)\<close>
      by (simp add: minimal_transitions_def \<Sigma>t_def)    
    then have "\<sigma>' - \<sigma> \<subseteq> M"
      using state_difference_is_valid_message by auto      
    then have "\<exists>m1 m2. {m1, m2} \<subseteq> M \<and> m1 \<in> \<sigma>' - \<sigma> \<and> m2 \<in> \<sigma>' - \<sigma> \<and> m1 \<noteq> m2"
      using non_empty_non_singleton_imps_two_elements 
            \<open>(\<sigma>, \<sigma>') \<in> minimal_transitions \<and> \<not> is_singleton (\<sigma>' - \<sigma>)\<close>  \<open>\<sigma>' - \<sigma> \<noteq> \<emptyset>\<close>
      by (metis (full_types) contra_subsetD insert_subset subsetI)
    then show "\<exists>m1 m2. {m1, m2} \<subseteq> M \<and> m1 \<in> \<sigma>' - \<sigma> \<and> m2 \<in> \<sigma>' - \<sigma> \<and> m1 \<noteq> m2 \<and> immediately_next_message (\<sigma>, m1)"
      using state_differences_have_immediately_next_messages
      by (metis Diff_iff \<open>\<sigma>' \<in> \<Sigma> \<and> \<sigma> \<in> \<Sigma> \<and> is_future_state (\<sigma>, \<sigma>')\<close> insert_subset message_in_state_is_valid)
  qed      
  have "\<forall> \<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions \<and> \<not> is_singleton (\<sigma>'- \<sigma>) \<longrightarrow>
              (\<exists> \<sigma>''. \<sigma>'' \<in> \<Sigma> \<and> is_future_state (\<sigma>, \<sigma>'') \<and> is_future_state (\<sigma>'', \<sigma>') \<and> \<sigma> \<noteq> \<sigma>'' \<and> \<sigma>'' \<noteq> \<sigma>')"
    apply (rule, rule, rule)
  proof -
    fix \<sigma> \<sigma>'
    assume "(\<sigma>, \<sigma>') \<in> minimal_transitions \<and> \<not> is_singleton (\<sigma>' - \<sigma>)"
    then have "\<exists> m1 m2. {m1, m2} \<subseteq> M \<and> m1 \<in> \<sigma>'- \<sigma> \<and> m2 \<in> \<sigma>'- \<sigma> \<and> m1 \<noteq> m2 \<and> immediately_next_message (\<sigma>, m1)"
      using \<open>\<forall> \<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions \<and> \<not> is_singleton (\<sigma>'- \<sigma>)
    \<longrightarrow> (\<exists> m1 m2. {m1, m2} \<subseteq> M \<and> m1 \<in> \<sigma>'- \<sigma> \<and> m2 \<in> \<sigma>'- \<sigma> \<and> m1 \<noteq> m2 \<and> immediately_next_message (\<sigma>, m1))\<close>
      by simp
    then obtain m1 m2 where "{m1, m2} \<subseteq> M \<and> m1 \<in> \<sigma>'- \<sigma> \<and> m2 \<in> \<sigma>'- \<sigma> \<and> m1 \<noteq> m2 \<and> immediately_next_message (\<sigma>, m1)"
      by auto
    have "\<sigma> \<in> \<Sigma> \<and> \<sigma>' \<in> \<Sigma>"
      using \<open>(\<sigma>, \<sigma>') \<in> minimal_transitions \<and> \<not> is_singleton (\<sigma>' - \<sigma>)\<close>
      by (simp add: minimal_transitions_def \<Sigma>t_def)
    then have "\<sigma> \<union> {m1} \<in> \<Sigma>"
      using \<open>{m1, m2} \<subseteq> M \<and> m1 \<in> \<sigma>'- \<sigma> \<and> m2 \<in> \<sigma>'- \<sigma> \<and> m1 \<noteq> m2 \<and> immediately_next_message (\<sigma>, m1)\<close>
            state_transition_by_immediately_next_message
      by simp
    have "is_future_state (\<sigma>, \<sigma> \<union> {m1}) \<and> is_future_state (\<sigma> \<union> {m1}, \<sigma>')"
      using \<open>(\<sigma>, \<sigma>') \<in> minimal_transitions \<and> \<not> is_singleton (\<sigma>' - \<sigma>)\<close> \<open>{m1, m2} \<subseteq> M \<and> m1 \<in> \<sigma>' - \<sigma> \<and> m2 \<in> \<sigma>' - \<sigma> \<and> m1 \<noteq> m2 \<and> immediately_next_message (\<sigma>, m1)\<close> minimal_transitions_def by auto
    have "\<sigma> \<noteq> \<sigma> \<union> {m1} \<and> \<sigma> \<union> {m1} \<noteq> \<sigma>'"
      using \<open>{m1, m2} \<subseteq> M \<and> m1 \<in> \<sigma>' - \<sigma> \<and> m2 \<in> \<sigma>' - \<sigma> \<and> m1 \<noteq> m2 \<and> immediately_next_message (\<sigma>, m1)\<close> by auto
    then show " \<exists>\<sigma>''. \<sigma>'' \<in> \<Sigma> \<and> is_future_state (\<sigma>, \<sigma>'') \<and> is_future_state (\<sigma>'', \<sigma>') \<and> \<sigma> \<noteq> \<sigma>'' \<and> \<sigma>'' \<noteq> \<sigma>'"    
      using \<open>\<sigma> \<union> {m1} \<in> \<Sigma>\<close> \<open>is_future_state (\<sigma>, \<sigma> \<union> {m1}) \<and> is_future_state (\<sigma> \<union> {m1}, \<sigma>')\<close>
      by auto      
  qed
  then show False
    using \<open>\<forall>\<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions \<longrightarrow> (\<nexists>\<sigma>''. \<sigma>'' \<in> \<Sigma> \<and> is_future_state (\<sigma>, \<sigma>'') \<and> is_future_state (\<sigma>'', \<sigma>') \<and> \<sigma> \<noteq> \<sigma>'' \<and> \<sigma>'' \<noteq> \<sigma>')\<close> \<open>\<not> (\<forall>\<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions \<longrightarrow> is_singleton (\<sigma>' - \<sigma>))\<close> by blast
qed

lemma (in Protocol) minimal_transitions_reconstruction :
  "\<forall> \<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions  \<longrightarrow> \<sigma> \<union> {the_elem (\<sigma>'- \<sigma>)} = \<sigma>'"
  apply (rule, rule, rule)
proof -
  fix \<sigma> \<sigma>'
  assume "(\<sigma>, \<sigma>') \<in> minimal_transitions"
  then have "is_singleton (\<sigma>'- \<sigma>)"
    using  minimal_transitions_def minimal_transition_implies_recieving_single_message by auto 
  then have "\<sigma> \<subseteq> \<sigma>'"
    using \<open>(\<sigma>, \<sigma>') \<in> minimal_transitions\<close> minimal_transitions_def by auto
  then show "\<sigma> \<union> {the_elem (\<sigma>'- \<sigma>)} = \<sigma>'"
    by (metis Diff_partition \<open>is_singleton (\<sigma>' - \<sigma>)\<close> is_singleton_the_elem)
qed

(* NOTE: This lemma will be unnecessary if we directly consider immediately next message as minimal step *)
lemma (in Protocol) minimal_transition_is_immediately_next_message :
  "\<forall> \<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions \<longleftrightarrow> immediately_next_message (\<sigma>, the_elem (\<sigma>'- \<sigma>))"
proof -
  have "\<forall> \<sigma> \<sigma>'. (\<sigma>, \<sigma>') \<in> minimal_transitions \<longrightarrow> immediately_next_message (\<sigma>, the_elem (\<sigma>'- \<sigma>))"
    using minimal_transition_implies_recieving_single_message state_transition_only_made_by_immediately_next_message
          state_differences_have_immediately_next_messages
          state_difference_is_valid_message
    apply (simp add: minimal_transitions_def immediately_next_message_def)
    (* by (smt Diff_iff \<Sigma>t_is_subset_of_\<Sigma> is_singleton_the_elem singletonD subsetCE) *)
oops
    

lemma (in Protocol) road_to_future_state :
  "\<forall> \<sigma> \<sigma>'. \<sigma> \<in> \<Sigma> \<and> \<sigma>' \<in> \<Sigma> \<and> is_future_state(\<sigma>, \<sigma>')
  \<longrightarrow> n = card (\<sigma>' - \<sigma>)  
  \<longrightarrow> (\<exists> f. f 0 = \<sigma> \<and> f n = \<sigma>' \<and> (\<forall> i. 0 \<le> i \<and> i \<le> n - 1 \<longrightarrow> f i \<in> \<Sigma> \<and> (\<exists> m \<in> M. f i \<union> {m} = f (Suc i))))" 
  apply (rule, rule, rule, rule) 
  oops

end