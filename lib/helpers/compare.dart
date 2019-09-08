import 'package:collection/collection.dart';

class Compare {
  //var compareList = IterableEquality();
  static List<int> matchLists(List<int> list, List<List<int>> list2D) {
    var compareList = IterableEquality();
    var matchingCell = list2D
        .firstWhere((cell) => compareList.equals(cell, list), orElse: () => []);

    return matchingCell;
  }

  static List<List<int>> createListOfMatchingLists(
      List<List<int>> list1, List<List<int>> list2) {
    List<List<int>> cellsToKeep = [];
    list1.forEach((oldCell) {
      var matchingCell = matchLists(oldCell, list2);
      if (matchingCell.isNotEmpty) {
        cellsToKeep.add(matchingCell);
      }
    });
    return cellsToKeep;
  }
}
