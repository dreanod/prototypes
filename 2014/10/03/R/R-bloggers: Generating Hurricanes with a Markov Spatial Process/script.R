library(XML)
extract.track = function(year = 2012, p = TRUE) {
  loc <- paste("http://weather.unisys.com/hurricane/atlantic/", 
               year, "/index.php", sep="")
  tabs <- readHTMLTable(htmlParse(loc), skip.rows=1)
  storms <- unlist(strsplit(as.character(tabs[[1]]$V2), split=" "))
  index <- storms %in% c("Tropical", "Storm", paste("Hurricane-", 1:6, sep=""), 
                         "Depression", "Subtropical", "Extratropical", 
                         paste("Storm-", 1:6, sep=""), "Xxx")
  nstorms <- storms[!index]
  
  TRACK = NULL
  for (i in length(nstorms):1) {
    if (nstorms[i] != 'Low') {
      if (nstorms[i] == "SIXTEE") {
        nstorms[i] = "SIXTEEN"
      }
      if (nstorms[i] == "LAUR") {
        nstorms[i] = "LAURA"
      }
      if (nstorms[i] == "FIFTEE") {
        nstorms[i] = "FIFTEEN"
      }
      if (nstorms[i] == "CHANTA") {
        nstorms[i] = "CHANTAL"
      }
      if (nstorms[i] == "ANDR") {
        nstorms[i] = "ANDREA"
      }
      if (nstorms[i] == "NINETE") {
        nstorms[i] = "NINETEEN"
      }
      if (nstorms[i] == "JOSEPH") {
        nstorms[i] = "JOSEPHINE"
      }
      if (nstorms[i] == "FLOY") {
        nstorms[i] = "FLOYD"
      }
      if (nstorms[i] == "KEIT") {
        nstorms[i] = "KEITH"
      }
      if (nstorms[i] == "CHARLI") {
        nstorms[i] = "CHARLIE"
      }
      
      
      
      loc = paste("http://weather.unisys.com/hurricane/atlantic/", year, "/",
                  nstorms[i], "/track.dat", sep="")
      print(loc)
      track = read.fwf(loc, skip=3, widths = c(4, 6, 8, 12, 4, 6, 20))
      names(track) = c("ADV", "LAT", "LON", "TIME", "WIND", "PR", "STAT")
      track$LAT = as.numeric(as.character(track$LAT))
      track$LON = as.numeric(as.character(track$LON))
      track$WIND = as.numeric(as.character(track$WIND))
      track$PR = as.numeric(as.character(track$PR))
      track$year = year
      track$name = nstorms[i]
      TRACK = rbind(TRACK, track)
      if (p == TRUE) {
        cat(year, i, nstorms[i], nrow(track), "\n")
      }
    }
  }
  return(TRACK)
}

# m <- extract.track()

TOTTRACK <- NULL
for (y in 2012:1851) {
  TOTTRACK = rbind(TOTTRACK, extract.track(y))
}

library(maps)
map("world", xlim=c(-110, 0), ylim=c(0, 70), col="light yellow", fill=TRUE)
for (n in unique(TOTTRACK$name)) {
  lines(TOTTRACK$LON[TOTTRACK$name == n], TOTTRACK$LAT[TOTTRACK$name == n], 
        lwd=.5, col="red")
}

library(ks)
U = TOTTRACK[, C("LON", "LAT")]
U = U[!is.na(U$LON),]
H = diag(c(.2, .2))
fat = kde(U, H, xmin=c(min(U[,1]), min(U[.2])), xmax=c(max(U[,1]), max(U[,2])))
z = fat$estimate
image(z)
map("world", add = TRUE)

mtransition = function(i, j) {
  MOVEMENT = NA
  sumstop = 0
  p = 1
  idx = which((TOTTRACK$LON >= gridx[i]) &
              (TOTTRACK$LON < gridx[i + 1]) &
              (TOTTRACK$LAT >= gridy[j]) &
              (TOTTRACK$LAT < gridy[j+1]))
  if (length(idx) > 0) {
    MOVEMENT = data.frame(LON = rep(NA, length(idx)),
                          LAT = rep(NA, length(idx)),
                          D   = rep(NA, length(idx)))
    for (s in 1:length(idx)) {
      stops = TRUE
      if ((is.na(TOTTRACK$name[idx[s] + 1]) == FALSE) &
          (is.na(TOTTRACK$name[idx[s]]) == FALSE)) {
        stops = TOTTRACK$name[idx[s] + 1] != TOTTRACK$name[idx[s]]
      }
      if (stops == TRUE) {
        sumstop = sumstop + 1
      }
      if (stops == FALSE) {
        d = (TOTTRACK$LON[idx[s] + 1] - TOTTRACK$LON[idx[s]])^2 + (TOTTRACK$LAT[idx[s] + 1] - TOTTRACK$LAT[idx[s]])^2
        locx = locy = NA
        if ((d < 90) & TOTTRACK$LON[idx[s] + 1] < 0) {
          locx = floor(TOTTRACK$LON[idx[s] + 1] / pasgrid)
          locy = floor(TOTTRACK$LAT[idx[s] + 1] / pasgrid)
        }
        MOVEMENT[s,] = c(locx, locy, d)
      }
    }
    p = sumstop / length(idx)
  }
  return(list(listemouv = MOVEMENT, probstop = p))
}