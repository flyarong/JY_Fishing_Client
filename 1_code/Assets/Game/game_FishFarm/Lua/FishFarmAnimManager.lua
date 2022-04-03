-- 创建时间:2020-11-17

FishFarmAnimManager = {}

function FishFarmAnimManager.PlayNewAddFish(parent, data)
	local prefab = CachePrefabManager.Take("fishbowl_new_fish")
	prefab.prefab:SetParent(parent)
    prefab.prefab.prefabObj.transform.localPosition = Vector3.zero

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(2)
    seq:OnForceKill(function()
        CachePrefabManager.Back(prefab)
    end)
end


