class Loan {
  int? id;
  int bookId;
  int memberId;
  DateTime loanDate;
  DateTime? returnDate;
  String? bookTitle;
  String? memberName;

  Loan({
    this.id,
    required this.bookId,
    required this.memberId,
    required this.loanDate,
    this.returnDate,
    this.bookTitle,
    this.memberName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'member_id': memberId,
      'loan_date': loanDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'],
      bookId: map['book_id'],
      memberId: map['member_id'],
      loanDate: DateTime.parse(map['loan_date']),
      returnDate: map['return_date'] != null ? DateTime.parse(map['return_date']) : null,
      bookTitle: map['book_title'],
      memberName: map['member_name'],
    );
  }
}