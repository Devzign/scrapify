import '../data/models/help_support_ticket_model.dart';

class HelpSupportState {
  final bool isLoading;
  final bool isSubmitting;
  final List<HelpSupportTicketModel> tickets;
  final String? error;

  const HelpSupportState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.tickets = const [],
    this.error,
  });

  HelpSupportState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<HelpSupportTicketModel>? tickets,
    String? error,
    bool clearError = false,
  }) {
    return HelpSupportState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      tickets: tickets ?? this.tickets,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
