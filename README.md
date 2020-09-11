# Offline-Fighting-Game-Data-App
A companion app for fighting games (i.e. Street Fighter). Allows users to record their wins and losses in fighting games against friends, and compare their stats against their friends, and track their own stats to assess strength with certain characters or teams (in the case of team fighters). The aim of the app is to provide revealing data to players who are particularly interested in matchups from a data perspective, to complement the perspective from tier lists and from intuition.

Uses SQL libraries to record and handle data queries. Was my first real experience of async programming. I am fairly fond of the data class structures I created, as they are built such that they could open up the possibilities of users adding their own data fields that may interest them. However it is admittedly clunky, especially how I go between class structures, json and SQL less than neatly (each has advantages and disadvantages).

Abandoned fairly late into development. Only provides rudimentary fighter matchup data. Was supposed to add friend comparison data, but instead it just shows a listview of the raw fighting records. I have since moved on to develop an online version which would provide the benefits of Cloud data pooling and add a more social dimension to challenging friends and acquaintances, as well as fulfilling all the aims of this prototype.

Status: Deprecated
