-- 创建时间:2018-12-25

ExtendSoundManager = {}

local C = ExtendSoundManager

function C.Init()
	C.lastAudioName = nil
	C.oldAudioName = nil
end
-- 播放场景背景音乐
function C.PlaySceneBGM(audioName, isCoerce)
	if not C.lastAudioName then
		soundMgr:PlayBGM(audioName, MainModel.sound_pattern)
		C.lastAudioName = audioName
		C.oldAudioName = audioName
	else
		C.oldAudioName = C.lastAudioName
		if isCoerce then
			soundMgr:PlayBGM(audioName, MainModel.sound_pattern)
			C.lastAudioName = audioName
		else
			if C.lastAudioName ~= audioName then
				soundMgr:PlayBGM(audioName, MainModel.sound_pattern)
				C.lastAudioName = audioName
			end
		end
	end
end

function C.PlayOldBGM()
	if not C.oldAudioName then
		soundMgr:PlayBGM(audio_config.game.bgm_main_hall.audio_name, MainModel.sound_pattern)
		C.lastAudioName = audio_config.game.bgm_main_hall.audio_name
		C.oldAudioName = C.lastAudioName
	else
		soundMgr:PlayBGM(C.oldAudioName, MainModel.sound_pattern)
		C.lastAudioName = C.oldAudioName
		C.oldAudioName = C.lastAudioName
	end
end

function C.PlayLastBGM()
	if not C.lastAudioName then
		soundMgr:PlayBGM(audio_config.game.bgm_main_hall.audio_name, MainModel.sound_pattern)
		C.lastAudioName = audio_config.game.bgm_main_hall.audio_name
		C.oldAudioName = C.lastAudioName
	else
		soundMgr:PlayBGM(C.lastAudioName, MainModel.sound_pattern)
		C.lastAudioName = C.lastAudioName
		C.oldAudioName = C.lastAudioName
	end
end

-- 暂停场景背景音乐
function C.PauseSceneBGM()
	soundMgr:PauseBG()
	C.lastAudioName = nil
end

-- 播放音效
function C.PlaySound(audioName, loopNum, call)
	loopNum = loopNum or 1
	return soundMgr:PlaySound(audioName, loopNum, call, MainModel.sound_pattern)
end
-- 播放音效
function C.CloseSound(audio_key)
	if audio_key then
		soundMgr:CloseLoopSound(audio_key)
	end
	return
end

function C.GetOldAudioName()
	return C.oldAudioName
end