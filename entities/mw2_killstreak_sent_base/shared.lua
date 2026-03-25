ENT.Type 			= "anim"
ENT.Author			= "Death dealer142"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.Friendlys = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman" , "npc_maxine_caulfield", "npc_maxine_caulfield_rachel", "npc_chloe_price", "npc_anna", "npc_elsa", "npc_goth_elsa", "npc_super_companion", "npc_lizzy", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_vj_milifri_ranger_2", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_swat", "npc_swat_2" }

function ENT:IsFriendly(tar)
	if tar:IsNPC() && table.HasValue(self.Friendlys, tar:GetClass()) then return true end
	if tar:IsPlayer() && ( tar == self.Owner || tar:Team() == self.Owner:Team() ) then return true end
	
	return false;
end

function ENT:GetPossilbeTargets()
	local enttable = ents.FindByClass("npc_*")
	local monstertable = ents.FindByClass("monster_*")
	local playertable = player.GetAll()
	table.Add(enttable, monstertable)
	table.Add(enttable, playerTable)
	return enttable;	
end