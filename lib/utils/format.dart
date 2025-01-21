String formatElapsedTime(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}


int parseSpeed(String speed){
  
  /* This will parse a string in the format min:sec and return the value in seconds */
  List<String> splitted = speed.split(":");
  return int.parse(splitted[0])*60 + int.parse(splitted[1]);
}