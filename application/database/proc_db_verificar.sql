drop procedure if exists `db_verificar`;
delimiter //
create procedure `db_verificar`()
	language sql
	not deterministic
	contains sql
	sql security definer
	comment ''
begin
	declare secao varchar(200);

	set secao = 'Consistência com Moodle';

		select secao, 'disciplinas_turmas.id_mdl_course = cursos inexistentes no Moodle';
		select *
		from disciplinas_turmas dt
		where dt.id_mdl_course is not null
			and not exists (
				select 1 from lmsinfne_mdl.mdl_course crs
				where crs.id = dt.id_mdl_course
			);

		select secao, 'turmas.id_mdl_course_category = categorias inexistentes no Moodle';
		select *
		from turmas t
		where t.id_mdl_course_category is not null
			and not exists (
				select 1 from lmsinfne_mdl.mdl_course_categories c
				where c.id = t.id_mdl_course_category
			);

		select secao, 'avaliacoes_mdl_course_modules.instance_mdl_course_modules = módulos inexistentes no Moodle';
		select *
		from avaliacoes_mdl_course_modules acm
		where not exists (
			select 1 from lmsinfne_mdl.mdl_course_modules cm
			where cm.instance = acm.instance_mdl_course_modules
		);

		select secao, 'subcompetencias_mdl_gradingform_rubric_criteria.id_mdl_gradingform_rubric_criteria = rubricas inexistentes no Moodle';
		select *
		from subcompetencias_mdl_gradingform_rubric_criteria scmpgrc
		where not exists (
			select 1 from lmsinfne_mdl.mdl_gradingform_rubric_criteria grc
			where grc.id = scmpgrc.id_mdl_gradingform_rubric_criteria
		);

	set secao = 'Consistência de campos atualizados por trigger';

		select secao, 'turmas.qtd_disciplinas_calc';
		select t.*
		from turmas t
			left join (
				select id_turma,
					COUNT(1) cnt
	            from disciplinas_turmas
	        	group by id_turma
			) dt on dt.id_turma = t.id
		where t.qtd_disciplinas_calc <> COALESCE(dt.cnt, 0);

		select secao, 'subcompetencias.codigo_completo_calc';
		select *
		from subcompetencias scmp
			join competencias cmp on cmp.id = scmp.id_competencia
		where scmp.codigo_completo_calc <> CONCAT(cmp.codigo, '.', scmp.codigo, case when scmp.obrigatoria = 1 then '*' else '' end);

		select secao, 'disciplinas_turmas.id_bloco_red';
		select *
		from disciplinas_turmas dt
			join disciplinas d on d.id = dt.id_disciplina
			left join blocos b on b.id = d.id_bloco
		where b.id <> dt.id_bloco_red;

		select secao, 'turmas.id_escola_red';
		select *
		from turmas t
			join programas p on p.id = t.id_programa
			join escolas e on e.id = p.id_escola
		where e.id <> t.id_escola_red;

		select secao, 'subcompetencias.id_disciplina_turma_red';
		select *
		from subcompetencias scmp
			join competencias cmp on cmp.id = scmp.id_competencia
		where scmp.id_disciplina_turma_red <> cmp.id_disciplina_turma;
end//
delimiter ;
