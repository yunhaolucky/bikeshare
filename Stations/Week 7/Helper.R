print.csv <- function(file_name, ...){
  # Print serveral list in the format of data frame in a csv file
  # Args:
  #   file_name : the name of the output file
  #   ... : all list that needs added to the data frame
  # Returns:
  #   NA
  output <- data.frame(...)
  write.csv(output, file = file_name, quote=FALSE, row.names=FALSE)
  remove(output)
}


min_to_time <- function(minute){
  return(paste(minute %/% 60, ":", minute %% 60, sep = ""))
}

time_to_min <- function(time){
  # Return num of minutes after 00:00 at the current time
  # Args:
  #   time(string): time in the format of "%m/%d/%Y %H:%M" or "%Y-%m-%d %H:%M:%S"
  # Return:
  #   number of minutes range(0-1440)
  temp = as.POSIXlt(strptime(time,"%m/%d/%Y %H:%M"))
  if(is.na(temp) == FALSE){
    return(temp[[2]]+temp[[3]]*60)
  }else{
    temp = as.POSIXlt(strptime(time,"%Y-%m-%d %H:%M:%S"))
    return(temp[[2]]+temp[[3]]*60)
  }
}


station.id_to_index <- function(id){
  return(which(stations==id))
}

station.get_start_degree <- function(station,minute){
  return(start_by_stations[[station.id_to_index(station)]][minute+1])
}

station.get_end_degree <- function(station,minute){
  return(end_by_stations[[station.id_to_index(station)]][minute+1])
}

station.get_net_degree <- function(station,minute){
  return(end_by_stations[[station.id_to_index(station)]][minute+1] - start_by_stations[[station.id_to_index(station)]][minute+1])
}

list.mean_by_chucks<- function(list, n){
  # Calculate the mean of list by chucks
  # Args:
  #  list:
  #  n: size of chucks
  # Return:
  #   a list with mean of chucks
  # Use: Given daily date, Calcualte Monthly mean
  temp = tapply(list, rep(1:ceiling(length(list)/n), each = n, length.out = length(list)), mean)
  temp = as.vector(temp)
  return(temp)
}

list.range_by_list <- function(range, n){
  return(list.mean_by_chucks(c(1:range),n))
}

ridership.get_day <- function(ridelist,date){
  # Get the ridership data from one single day
  # Args:
  #   ridelist: (data.frame) ridership history data from Capital Bike Website
  #   date:(string) in the format of "%m/%d/%Y"
  # Return:
  #    if ridelist does not contain data on `date` print `Not exsit`
  #    else return all rideship date on `date`
  #TODO: Binary search
  tempdate = as.POSIXlt(strptime(date,"%m/%d/%Y"))
  start = 0
  end = 0
  for( i in c(1:nrow(ridelist))){
    if(start == 0){
      mid.date = as.POSIXlt(strptime(ridelist$Start.date[i],"%m/%d/%Y"))
      if(mid.date == tempdate){
        print(mid.date)
        start = i
      }
    }else if(end == 0){
      mid.date = as.POSIXlt(strptime(ridelist$Start.date[i],"%m/%d/%Y"))
      if(mid.date != tempdate){
        end = i - 1
      }
    }
  }
  if(start == 0){
    print("Not exsit")
  }else if (end == 0){
    end = nrow(ridelist)
  }
  resultlist = ridelist[c(start:end),]
  return(resultlist)
}

list.add_min_distance<-function(list){
  # Add min and distance column to the ridershipt list
  # Args:
  #   list:(data.frame) each row represents a ridership
  #         return value of ridership.get_day
  #          must has column State.date. End.date, Start.terminal, End.terminal,Subscription.Type
  # Return:
  #    data.frame with col start(min), end(min),sta_s(station_id), sta_e, type("Casual", "Registered", distance(mile))
  temp.start = sapply(list$Start.date,time_to_min)
  temp.end = sapply(list$End.date,time_to_min)
  temp.sta_s = list$Start.terminal
  temp.sta_e = list$End.terminal
  temp.type = list$Subscription.Type
  temp.distance = apply(data.frame(temp.sta_s, temp.sta_e), 1, function(x) distance(x[1],x[2]))
  return(data.frame(start = temp.start,end = temp.end, start_station = temp.sta_s,end_station = temp.sta_e,type = temp.type,distance = temp.distance))
}

