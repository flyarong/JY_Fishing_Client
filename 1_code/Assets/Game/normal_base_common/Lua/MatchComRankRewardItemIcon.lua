local basefunc = require "Game.Common.basefunc"

MatchComRankRewardItemIcon = basefunc.class()
MatchComRankRewardItemIcon.name = "MatchComRankRewardItemIcon"

function MatchComRankRewardItemIcon.Create(data, parent)
    return MatchComRankRewardItemIcon.New(data, parent)
end

function MatchComRankRewardItemIcon:ctor(data, parent)
    --log("IconBg:" .. imgBg .. ", Icon:" .. imgIcon .. ", Desc:" .. desc .. ", Rank:" .. imgRank)
    if parent then
        self.parent = parent
        self.config = data
        self.Icon = newObject("MatchComRankRewardItemIcon", self.parent.transform)
        self.transform = self.Icon.transform
        LuaHelper.GeneratingVar(self.Icon.transform, self)

        self:SetBg("matchpop_bg_jl")
        self:SetDesc(self.config.award)
        self:SetIconImage(self.config.icon)
    else
        self:Close()
    end
end

function MatchComRankRewardItemIcon:SetScale(scale)
    if self.Icon then
        self.Icon.transform.localScale = scale
    end
end

function MatchComRankRewardItemIcon:SetBg(imgBg)
    local config = self.config
    if config.rank == "第1名" then
        imgBg = imgBg .. "1"
    elseif config.rank == "第2名" then
        imgBg = imgBg .. "2"
    elseif config.rank == "第3名" then
        imgBg = imgBg .. "3"
    end

    if self.stage_img and imgBg then
        local cImg = self.stage_img.gameObject:GetComponent("Image")
        if cImg then
            local sp = GetTexture(imgBg)
	    if not sp then
	    	--default
	    	sp = GetTexture("matchpop_bg_jl4")
	    end
            cImg.sprite = sp
            cImg:SetNativeSize()
        end
    end
end

function MatchComRankRewardItemIcon:SetDesc(desc)
    if desc and self.desc_txt then
        if string.find(desc,"+") then
            local s = desc
            s = split(s,"+")
            self.desc_txt.text = s[1]
        else
            self.desc_txt.text = desc
        end        
    end
end

function MatchComRankRewardItemIcon:SetIconSize(w, h)
    if self.item_img then
        local rt = self.item_img.gameObject:GetComponent("RectTransform")
        if rt then
            rt.sizeDelta = {x = w, y = h}
        end
    end
end

function MatchComRankRewardItemIcon:SetIconLocation(x, y)
    if self.item_img then
        local rt = self.item_img.gameObject:GetComponent("RectTransform")
        if rt then
            rt.localPosition = Vector2.New(x, y)
        end
    end
end

function MatchComRankRewardItemIcon:SetIconImage(imgIcon)
    local config = self.config
    local setSize = function ()
        -- self.item_img:SetNativeSize()
        if config.rank == "第2名" or config.rank == "第3名" then
            if self.item_img then
                self.item_img.transform.localScale = Vector3.New(0.8,0.8,1)
                self.item_img.transform.localPosition = Vector3.New(0,40,0)
            end
        elseif config.rank == "第1名" then
            if self.item_img then
                self.item_img.transform.localScale = Vector3.New(1,1,1)
                self.item_img.transform.localPosition = Vector3.New(0,60,0)
            end
        end
    end
    if imgIcon and self.item_img then
        if config.is_local_icon == 1 then
            self.item_img.sprite = GetTexture(imgIcon)
            setSize()
        else
            setSize()
            URLImageManager.UpdateWebImage(imgIcon, self.item_img)
        end
    end
end

function MatchComRankRewardItemIcon:SetLocation(x, y)
    if self.Icon then
        local rt = self.Icon.gameObject:GetComponent("RectTransform")
        if rt then
            rt.localPosition = Vector2.New(x, y)
        end
    end
end

function MatchComRankRewardItemIcon:SetSize(w, h)
    if self.Icon then
        local rt = self.Icon.gameObject:GetComponent("RectTransform")
        if rt then
            rt.sizeDelta = {x = w, y = h}
        end
    end
end

function MatchComRankRewardItemIcon:SetDescSize(w, h)
    if self.desc_txt then
        local rt = self.desc_txt.gameObject:GetComponent("RectTransform")
        if rt then
            rt.sizeDelta = {x = w, y = h}
        end
    end
end

function MatchComRankRewardItemIcon:SetDescLocation(x, y)
    if self.desc_txt then
        local rt = self.desc_txt.gameObject:GetComponent("RectTransform")
        if rt then
            rt.localPosition = Vector2.New(x, y)
        end
    end
end

function MatchComRankRewardItemIcon:Close()
    if self.Icon then
        destroy(self.Icon.gameObject)
    end
    closePanel(MatchComRankRewardItemIcon.name)
end