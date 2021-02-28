using System.Net;
using System.Net.Mail;

namespace SI.Common.Helpers
{
    /// <summary>
    /// Provides helper functionality for SMTP email.
    /// </summary>
    public static class SmtpHelper
    {
        /// <summary>
        /// Send an email message using SMTP.
        /// </summary>
        /// <param name="subject">The email subject.</param>
        /// <param name="body">The message  body.</param>
        /// <param name="from">The from address.</param>
        /// <param name="password">The password for the from address.</param>
        /// <param name="to">The recipient address.</param>
        public static void Send(string subject, string body, string from, string password, string to)
        {
            //Due to Google's security settings this only works if you allow less secure apps to send email via the following link https://myaccount.google.com/lesssecureapps
            var mail = new MailMessage() { Subject = subject, Body = body };
            mail.To.Add(new MailAddress(to));
            mail.From = new MailAddress(from);

            var client = new SmtpClient
            {
                Port = 587,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                UseDefaultCredentials = false,
                Host = "smtp.gmail.com",
                Timeout = 10000,
                EnableSsl = true,
                Credentials = new NetworkCredential(from, password)
            };

            client.Send(mail);
        }
    }
}
