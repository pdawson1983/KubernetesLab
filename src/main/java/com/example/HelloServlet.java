package com.example;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/hello")
public class HelloServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        String name = request.getParameter("name");
        if (name == null || name.trim().isEmpty()) {
            name = "World";
        }
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Liberty Test</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; text-align: center; margin: 50px; }");
        out.println(".container { max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ccc; border-radius: 10px; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='container'>");
        out.println("<h1>🚀 WebSphere Liberty Test</h1>");
        out.println("<h2>Hello, " + name + "!</h2>");
        out.println("<p>Your Liberty application is working!</p>");
        out.println("<hr>");
        out.println("<p><strong>Server Info:</strong> " + getServletContext().getServerInfo() + "</p>");
        out.println("<p><strong>Current Time:</strong> " + new java.util.Date() + "</p>");
        out.println("<p><a href='?name=Liberty'>Try with name=Liberty</a></p>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
}