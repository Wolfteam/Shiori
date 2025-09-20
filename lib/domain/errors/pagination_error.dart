class PaginationError extends ArgumentError {
  PaginationError.cannotGoToNext() : super('Cannot go to the next page', 'nextPage');

  PaginationError.cannotGoToPrevious() : super('Cannot go to the previous page', 'previousPage');

  PaginationError.samePage(int currentPage) : super('We are already on the same page = $currentPage', 'currentPage');

  PaginationError.newPageIsLessThanFirstOne(int newPage, int fistPage)
    : super('The newPage = $newPage cannot be less than $fistPage');
}
