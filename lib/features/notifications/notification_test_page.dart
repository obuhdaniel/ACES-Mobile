import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart'; // Your notification service file

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({Key? key}) : super(key: key);

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _titleController = TextEditingController(text: 'Test Title');
  final TextEditingController _bodyController = TextEditingController(text: 'Test Body');
  final TextEditingController _payloadController = TextEditingController(text: 'test_payload');
  final TextEditingController _imageUrlController = TextEditingController(
    text: 'https://picsum.photos/400/200', // Sample image URL
  );
  final TextEditingController _notificationIdController = TextEditingController(text: '1');
  
  DateTime _selectedDate = DateTime.now().add(const Duration(minutes: 5));
  TimeOfDay _selectedTime = TimeOfDay.now();
  Day _selectedDay = Day.monday;
  
  bool _isInitialized = false;
  bool _permissionsGranted = false;
  List<PendingNotificationRequest> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize(
        onNotificationTap: (payload) {
          _showNotificationDialog('Notification Tapped', 'Payload: $payload');
        },
      );
      
      setState(() {
        _isInitialized = true;
      });
      
      await _checkPermissions();
      await _loadPendingNotifications();
    } catch (e) {
      _showErrorDialog('Initialization Error', e.toString());
    }
  }

  Future<void> _checkPermissions() async {
    final granted = await _notificationService.arePermissionsGranted();
    setState(() {
      _permissionsGranted = granted;
    });
  }

  Future<void> _loadPendingNotifications() async {
    final pending = await _notificationService.getPendingNotifications();
    setState(() {
      _pendingNotifications = pending;
    });
  }

  int _getNotificationId() {
    return int.tryParse(_notificationIdController.text) ?? 1;
  }

  void _showNotificationDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('Error: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isInitialized ? Icons.check_circle : Icons.error,
                  color: _isInitialized ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text('Service Initialized: $_isInitialized'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _permissionsGranted ? Icons.check_circle : Icons.warning,
                  color: _permissionsGranted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text('Permissions Granted: $_permissionsGranted'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 8),
                Text('Pending Notifications: ${_pendingNotifications.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notificationIdController,
              decoration: const InputDecoration(
                labelText: 'Notification ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Body',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _payloadController,
              decoration: const InputDecoration(
                labelText: 'Payload',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scheduling Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date'),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: _selectDate,
                        child: Text(
                          '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time'),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: _selectTime,
                        child: Text(
                          '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Day of Week'),
            const SizedBox(height: 4),
            DropdownButton<Day>(
              value: _selectedDay,
              isExpanded: true,
              onChanged: (Day? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDay = newValue;
                  });
                }
              },
              items: Day.values.map((Day day) {
                return DropdownMenuItem<Day>(
                  value: day,
                  child: Text(_getDayName(day)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(Day day) {
    switch (day) {
      case Day.monday: return 'Monday';
      case Day.tuesday: return 'Tuesday';
      case Day.wednesday: return 'Wednesday';
      case Day.thursday: return 'Thursday';
      case Day.friday: return 'Friday';
      case Day.saturday: return 'Saturday';
      case Day.sunday: return 'Sunday';
    }
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Tester'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingNotifications,
            tooltip: 'Refresh Pending Notifications',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildInputSection(),
            const SizedBox(height: 16),
            _buildSchedulingSection(),
            const SizedBox(height: 16),
            
            // Immediate Notifications
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Immediate Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      'Show Simple Notification',
                      () async {
                        try {
                          await _notificationService.showSimpleNotification(
                            id: _getNotificationId(),
                            title: _titleController.text,
                            body: _bodyController.text,
                            payload: _payloadController.text,
                          );
                          _showNotificationDialog('Success', 'Simple notification shown!');
                        } catch (e) {
                          _showErrorDialog('Error', e.toString());
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      'Show Image Notification',
                      () async {
                        try {
                          await _notificationService.showImageNotification(
                            id: _getNotificationId(),
                            title: _titleController.text,
                            body: _bodyController.text,
                            imageUrl: _imageUrlController.text,
                            payload: _payloadController.text,
                          );
                          _showNotificationDialog('Success', 'Image notification shown!');
                        } catch (e) {
                          _showErrorDialog('Error', e.toString());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Scheduled Notifications
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scheduled Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      'Schedule One-time Notification',
                      () async {
                        try {
                          final scheduledDateTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          );
                          
                          final success = await _notificationService.scheduleNotification(
                            id: _getNotificationId(),
                            title: _titleController.text,
                            body: _bodyController.text,
                            scheduledTime: scheduledDateTime,
                            payload: _payloadController.text,
                          );
                          
                          if (success) {
                            _showNotificationDialog(
                              'Success', 
                              'Notification scheduled for ${scheduledDateTime.toString()}'
                            );
                            await _loadPendingNotifications();
                          } else {
                            _showErrorDialog('Error', 'Failed to schedule notification');
                          }
                        } catch (e) {
                          _showErrorDialog('Error', e.toString());
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      'Schedule Daily Notification',
                      () async {
                        try {
                          final success = await _notificationService.scheduleDailyNotification(
                            id: _getNotificationId(),
                            title: _titleController.text,
                            body: _bodyController.text,
                            notificationTime: _selectedTime,
                            payload: _payloadController.text,
                          );
                          
                          if (success) {
                            _showNotificationDialog(
                              'Success', 
                              'Daily notification scheduled for ${_selectedTime.format(context)}'
                            );
                            await _loadPendingNotifications();
                          } else {
                            _showErrorDialog('Error', 'Failed to schedule daily notification');
                          }
                        } catch (e) {
                          _showErrorDialog('Error', e.toString());
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      'Schedule Weekly Notification',
                      () async {
                        try {
                          final success = await _notificationService.scheduleWeeklyNotification(
                            id: _getNotificationId(),
                            title: _titleController.text,
                            body: _bodyController.text,
                            day: _selectedDay,
                            notificationTime: _selectedTime,
                            payload: _payloadController.text,
                          );
                          
                          if (success) {
                            _showNotificationDialog(
                              'Success', 
                              'Weekly notification scheduled for ${_getDayName(_selectedDay)} at ${_selectedTime.format(context)}'
                            );
                            await _loadPendingNotifications();
                          } else {
                            _showErrorDialog('Error', 'Failed to schedule weekly notification');
                          }
                        } catch (e) {
                          _showErrorDialog('Error', e.toString());
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      'Schedule Todo Notification (30min before)',
                      () async {
                        try {
                          final deadline = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          );
                          
                          final success = await _notificationService.scheduleTodoNotification(
                            id: _getNotificationId(),
                            title: _titleController.text,
                            body: _bodyController.text,
                            deadline: deadline,
                            payload: _payloadController.text,
                          );
                          
                          if (success) {
                            _showNotificationDialog(
                              'Success', 
                              'Todo notification scheduled 30 minutes before deadline'
                            );
                            await _loadPendingNotifications();
                          } else {
                            _showErrorDialog('Error', 'Failed to schedule todo notification');
                          }
                        } catch (e) {
                          _showErrorDialog('Error', e.toString());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Management Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Management Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      'Request Permissions',
                      () async {
                        try {
                          final granted = await _notificationService.requestPermissions();
                          setState(() {
                            _permissionsGranted = granted;
                          });
                          _showNotificationDialog(
                            'Permissions', 
                            granted ? 'Permissions granted!' : 'Permissions denied!'
                          );
                        } catch (e) {
                          _showErrorDialog('Error', e.toString());
                        }
                      },
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      'Verify Scheduled Notifications',
                      () async {
                        try {
                          await _notificationService.verifyScheduledNotifications();
                          await _loadPendingNotifications();
                          _showNotificationDialog(
                            'Verification Complete', 
                            'Check console for details. Found ${_pendingNotifications.length} pending notifications.'
                          );
                        } catch (e) {
                          _showErrorDialog('Error', e.toString());
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      'Cancel Specific Notification',
                      () async {
                        try {
                          await _notificationService.cancelNotification(_getNotificationId());
                          _showNotificationDialog(
                            'Cancelled', 
                            'Notification #${_getNotificationId()} cancelled'
                          );
                          await _loadPendingNotifications();
                        } catch (e) {
                          _showErrorDialog('Error', e.toString());
                        }
                      },
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      'Cancel All Notifications',
                      () async {
                        try {
                          await _notificationService.cancelAllNotifications();
                          _showNotificationDialog('Cancelled', 'All notifications cancelled');
                          await _loadPendingNotifications();
                        } catch (e) {
                          _showErrorDialog('Error', e.toString());
                        }
                      },
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Pending Notifications List
            if (_pendingNotifications.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pending Notifications',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._pendingNotifications.map((notification) => ListTile(
                        leading: CircleAvatar(
                          child: Text(notification.id.toString()),
                        ),
                        title: Text(notification.title ?? 'No Title'),
                        subtitle: Text(notification.body ?? 'No Body'),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () async {
                            await _notificationService.cancelNotification(notification.id);
                            await _loadPendingNotifications();
                          },
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}