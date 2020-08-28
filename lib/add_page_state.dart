import 'package:flutter/material.dart';

import 'data_model.dart';

class AddPageState {

  // Activity status vars
  String pageName = 'Select Game';
  IconData pageIcon = Icons.games;
  int pageIndex = 0;

  int progress = -1;

  void ChangePageName(int index)
  {
      this.pageIndex = index;
      switch(index)
      {
        case 0:
          pageName = 'Select Game';
          pageIcon = Icons.games;
          break;
        case 1:
          pageName = 'Select Format';
          pageIcon = Icons.build;
          break;
        case 2:
          pageName = 'Select Players';
          pageIcon = Icons.group;
          break;
        case 3:
          pageName = 'Select Fighters';
          pageIcon = Icons.whatshot;
          break;
        case 4:
          pageName = 'Record Data';
          pageIcon = Icons.add_box;
          break;
      }
  }

  void ChangeProgress(int progress) {this.progress = progress;}

  bool MayProgress() {
    return pageIndex <= progress;
  }


}