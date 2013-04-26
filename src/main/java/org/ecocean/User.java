package org.ecocean;

import java.util.Date;
import java.io.Serializable;

/**
 * <code>User</code> stores information about a contact/user.
 * Examples: photographer, submitter
 * @author Ed Stastny
 */
public class User implements java.io.Serializable {
  
  
  private static final long serialVersionUID = -1261710718629763048L;
  // The user's full name
  private String fullName;
  //Primary email address
  private String emailAddress;
  // User's snail-mail address/location
  private String physicalAddress;
  //Primary phone number
  private String phoneNumber;
  //Organization or project affiliation
  private String affiliation;
  //Misc. information about this user
  private String notes;
  //Date of last update of this record, in ms
  private long dateInMilliseconds;
  private long userID;

  
  	private String username;
  	private String password ;
  	private String salt;
  
  	
  	//JDOQL required empty instantiator
  	public User(){}
  	
  	public User(String fullName, String emailAddress, String physicalAddress, String phoneNumber, String affiliation, String notes) {
  	  setFullName(fullName);
  	  setEmailAddress(emailAddress);
  	  setPhysicalAddress(physicalAddress);
  	  setPhoneNumber(phoneNumber);
  	  setAffiliation(affiliation);
  	  setNotes(notes);
  	}
  	
  	public User(String username,String password, String salt){
  	  setUsername(username);
  	  setPassword(password);
  	  setSalt(salt);
  	}

  public void RefreshDate()
  {
    this.dateInMilliseconds = new Date().getTime();
  }

  public String getFullName()
  {
    return this.fullName;
  }
  public void setFullName (String fullName)
  {
    if(fullName!=null){
      this.fullName = fullName;
    }
    else{
      this.fullName=null;
    }
    RefreshDate();
  }

  public String getEmailAddress ()
  {
    return this.emailAddress;
  }
  public void setEmailAddress (String emailAddress){
    if(emailAddress!=null){
      this.emailAddress = emailAddress;
    }
    else{this.emailAddress=null;}
    RefreshDate();
  }

  public String getPhysicalAddress ()
  {
    return this.physicalAddress;
  }
  public void setPhysicalAddress (String physicalAddress)
  {
    
    if(physicalAddress!=null){this.physicalAddress = physicalAddress;}
    else{this.physicalAddress=null;}
    RefreshDate();
  }

  public String getPhoneNumber ()
  {
    return this.phoneNumber;
  }
  public void setPhoneNumber (String phoneNumber)
  {
    if(phoneNumber!=null){this.phoneNumber = phoneNumber;}
    else{this.phoneNumber=null;}
    RefreshDate();
  }

  public String getAffiliation ()
  {
    return this.affiliation;
  }
  public void setAffiliation (String affiliation)
  {
    if(affiliation!=null){
      this.affiliation = affiliation;
    }
    else{this.affiliation=null;}
    RefreshDate();
  }

  public String getNotes ()
  {
    return this.notes;
  }
  public void setNotes (String notes)
  {
    this.notes = notes;
    RefreshDate();
  }

  public long getDateInMilliseconds ()
  {
    return this.dateInMilliseconds;
  }




  	public long getUserID() {
  		return userID;
  	}
  	public void setUserID(long userID) {
  		this.userID = userID;
  	}
  	public String getUsername() {
  		return username;
  	}
  	public void setUsername(String username) {
  		this.username = username;
  	}
  	public String getPassword() {
  		return password;
  	}
  	public void setPassword(String password) {
  		this.password = password;
  	}
  	
  	public void setSalt(String salt){this.salt=salt;}
  	public String getSalt(){return salt;}



}
