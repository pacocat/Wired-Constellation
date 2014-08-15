library(tuneR)
setWavPlayer("afplay")

pa = 10000    # パルス増幅倍数
pr = 5        # パルスリピート回数
sr = 44100    # サンプリング周波数
br = 24       # ビットレート
min_hz = 27.5 # 最低周波数
max_hz = 4186 # 最高周波数
ss = 340000   # 音速(mm)
pc = 5        # ピークの個数

#
# スペクトル→波形データ変換関数
#
# @param sp_r スペクトルデータ
# @param sname スペクトルデータ名
# @return 波形データ
#
makeWav <- function(sp_r, sname) {
  # 波長変換
  # 音速を340m/sと定義し恒星の波長6300Å~6700Åをピアノの音域に設定
  sp_min <- min(sp_r$V1)
  if (6300 < sp_min) sp_min <- 6300
  sp_max = max(sp_r$V1)
  if (sp_max < 6700) sp_max <- 6700

  max_wl <- ss/min_hz
  min_wl <- ss/max_hz
  
  # 光の波長→音の波長
  sp_sound <- data.frame(
    WL=(sp_r$V1-sp_min)/(sp_max-sp_min)*(max_wl-min_wl)+min_wl,
    PW=sp_r$V2
  )

  plot(sp_sound, main=paste(sname, "sound spectrum"), type="l")

  # ピーク値を取得
#  sp_sound <- subset(sp_sound, sp_sound$WL>ss/880)
  sp_peaks <- head(sp_sound[order(-sp_sound$PW),], pc)
  plot(sp_peaks, main=paste(sname, "sound peaks"))
  sp_peaks$WL <- as.integer(round(sp_peaks$WL))
  
  # ピーク値の周波数で正弦波を合成
  n = 1:(sr*pr) # データ数
  t = n/sr      # 時間(pr秒)
  wav <- 0

  for (i in 1:pc) {
    s <- sin(2*pi*t*ss/sp_peaks$WL[i]/2)*sp_peaks$PW[i];
    wav <- wav + s
  }

  plot(wav[1:1024], main=paste(sname, "wave"), type="l")
  wav
}

# グラフは2行2列表示
par(oma=c(2,2,2,2))
par(mfrow=c(2,2))

setwd("/Users/YOKOYAMA/Downloads/spectrum") # 作業ディレクトリは適宜変更
files  <- list.files()

for (file.name in files) {
  # 赤色スペクトルのみ取り込み
  if (regexpr('\\_r.txt$', file.name)  < 0) {
    next
  }
  
  sname <- sub('\\.[^.]*', "", file.name) # スペクトルデータ名

  # wavデータ作成
  red_data <- read.table(file.name)
  wav_data <- makeWav(red_data, sname)
  pulse <- as.integer(wav_data*pa)
  plot(pulse, main=paste(sname, "pulse"), type="l")
  
  # グラフ画像の保存
  dev.copy(png, file=paste(sname, ".png", sep=""))
  dev.off()

  # wavファイル作成
  file.wav <- sub('\\.[^.]*', ".wav", file.name)  
  wav = Wave(pulse, samp.rate=sr, bit=br)
  writeWave(normalize(wav,"24"), file.wav)
}
