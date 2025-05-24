# Email Confirmations

> **📌 Note:** This document is under development.



## Steps to Implement Email Confirmation for Print Files

1. **Set up a print queue** using the MTS option `PRT`.
2. **Define a process rule** that triggers when a specific transaction is processed.
3. **Develop a script** to read the printed file.

   The script will use the back-end command `idi` to:
   - Retrieve the transaction details.
   - Format them.
   - Send an email to the relevant parties (debit party, credit party, or other involved parties).

4. **Monitor the directory** where print files are stored.
5. **Create an email confirmation template** for customer notifications.
6. **Develop a script** (in **Perl, Java, or .NET Core**) to:
   - Read transaction details from the file.
   - Use the template to generate the email confirmation.
7. **Configure Postfix** to enable outgoing emails from your MTS box (**AIX or Linux**).

---

### ⚠️ Note:
The main challenge is **collecting recipient email information**. Transactions may not always include email data, requiring additional steps to retrieve it from the party's address, leading to extra processing.
