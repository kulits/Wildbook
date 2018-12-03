/*
 * The Shepherd Project - A Mark-Recapture Framework
 * Copyright (C) 2011 Jason Holmberg
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package org.ecocean.servlet;

import org.ecocean.CommonConfiguration;
import org.ecocean.Encounter;
import org.ecocean.Shepherd;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;


//Set alternateID for this encounter/sighting
public class EncounterSetLocationID extends HttpServlet {

  public void init(ServletConfig config) throws ServletException {
    super.init(config);
  }


  public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    doPost(request, response);
  }


  private void setDateLastModified(Encounter enc) {
    String strOutputDateTime = ServletUtilities.getDate();
    enc.setDWCDateLastModified(strOutputDateTime);
  }


  public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String context="context0";
    context=ServletUtilities.getContext(request);
    Shepherd myShepherd = new Shepherd(context);
    myShepherd.setAction("EncounterSetLocationID.class");
    //set up for response
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();
    boolean locked = false;
    boolean isOwner = true;

    if (request.getParameter("stuID") != null) {

      String oldCode = "";
      myShepherd.beginDBTransaction();
      String encNum = request.getParameter("number").trim();
      Encounter changeMe = myShepherd.getEncounter(encNum);
      setDateLastModified(changeMe);
      try {

        oldCode = changeMe.getStudySiteID();
        changeMe.setStudySiteID(stuID);
        changeMe.addComments("<p><em>" + request.getRemoteUser() + " on " + (new java.util.Date()).toString() + "</em><br>Changed location code from " + oldCode + " to " + stuID + ".</p>");

      } catch (Exception le) {
        locked = true;
        le.printStackTrace();
        myShepherd.rollbackDBTransaction();
      }

      if (!locked) {
        myShepherd.commitDBTransaction();
        out.println("<strong>Success:</strong> Encounter study site ID has been updated from " + oldCode + " to " + stuID + ".");
        response.setStatus(HttpServletResponse.SC_OK);
        String message = "Encounter #" + request.getParameter("number") + " study site ID has been updated from " + oldCode + " to " + stuID + ".";
        ServletUtilities.informInterestedParties(request, request.getParameter("number"), message,context);
      }
      else {

        out.println("<strong>Failure:</strong> Encounter study site ID was NOT updated because the record for this encounter is currently being modified by another user. Please try to add the location code again in a few seconds.");
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);

      }
    }
    else {

      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      out.println("<strong>Error:</strong> I don't have enough information to complete your request.");

    }

    out.close();
    myShepherd.closeDBTransaction();
  }
}