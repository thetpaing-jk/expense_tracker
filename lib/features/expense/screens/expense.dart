import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpenseScreenState();
}
class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Expenses",
              style: TextTheme.of(context).titleLarge,
            ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      child: Icon(Icons.add),
      ),
    );
  }
}